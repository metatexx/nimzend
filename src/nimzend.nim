# Minimal Zend Module

import macros

when defined(php504):
  const ZEND_MODULE_API_NO = 20100525
elif defined(php503):
  const ZEND_MODULE_API_NO = 20090626
else:
  const ZEND_MODULE_API_NO = 20090626
  #{.error:"You need to define the PHP version (php54 php53)".}

type
  ZendModuleEntry* = object # not {.packed.} !
    size: uint16
    zend_api: uint32
    zend_debug: uint8
    zts: uint8
    ini_entry: pointer #const struct _zend_ini_entry *ini_entry;
    deps: pointer #const struct _zend_module_dep *deps;
    name: cstring
    functions: pointer #const struct _zend_function_entry *functions;
    module_startup_func: pointer #int (*module_startup_func)(INIT_FUNC_ARGS);
    module_shutdown_func: pointer #int (*module_shutdown_func)(SHUTDOWN_FUNC_ARGS);
    request_startup_func: pointer #int (*request_startup_func)(INIT_FUNC_ARGS);
    request_shutdown_func: pointer #int (*request_shutdown_func)(SHUTDOWN_FUNC_ARGS);
    info_func: pointer #void (*info_func)(ZEND_MODULE_INFO_FUNC_ARGS);
    version: cstring
    globals_size: int64
    globals_ptr: pointer
    globals_ctor: pointer #void (*globals_ctor)(void *global);
    globals_dtor: pointer #void (*globals_dtor)(void *global);
    post_deactivate_func: pointer #int (*post_deactivate_func)(void);
    module_started: int32
    kind: uint8
    handle: pointer
    module_number: int32
    build_id: cstring

  ZendFunctionEntry* = object # not {.packed.} !
    fname: cstring
    handler: pointer #void (*handler)(INTERNAL_FUNCTION_PARAMETERS);
    arg_info: pointer #const struct _zend_internal_arg_info *arg_info;
    num_args: uint32
    flags: uint32

  ZendExecuteDataObj = object
    nix: pointer

  ZendExecuteData* = ptr ZendExecuteDataObj

  ZendTypes* = enum
    IS_NULL
    IS_LONG
    IS_DOUBLE
    IS_BOOL
    IS_ARRAY
    IS_OBJECT
    IS_STRING
    IS_RESOURCE
    IS_CONSTANT
    IS_CONSTANT_ARRAY
    IS_CALLABLE

  ZendValue = object {.union.}
    long: int64
    str: tuple[text: cstring, len: int64]

  ZValObj* = object #{.packed.}
    value: ZendValue
    refcountGC: uint32
    kind: uint8
    isRefGc: uint8

  ZVal* = ptr ZValObj

converter zendTypes*(x: ZendTypes): uint8 = x.uint8

# zend functions

proc zend_zval_type_name*(arg: ZVal): cstring {.stdcall,importc.}
proc zend_parse_parameters*(num: int, format: cstring): int {.importc: "zend_parse_parameters", varargs.}

proc emalloc*(size: int): pointer {.importc:"_emalloc".}
proc efree*(mem: pointer) {.importc:"_efree".}
proc estrdup*(txt: cstring): cstring {.importc:"_estrdup".}

# Our Functions

template returnString*(s) =
  returnValue.value.str.text = estrdup(s)
  returnValue.value.str.len = s.len
  returnValue.kind = IS_STRING
  return

template returnLong*(s) =
  returnValue.value.long = s
  returnValue.kind = IS_LONG
  return

template notDiscarded*(): bool =
  (retval_used == 1)

proc newParam(name: string, kind: string): NimNode {.compiletime.} =
  result = newNimNode(nnkIdentDefs)
  result.add newIdentNode(name)
  result.add newIdentNode(kind)
  result.add newEmptyNode()

proc newPtrParam(name: string, kind: string): NimNode {.compiletime.} =
  result = newNimNode(nnkIdentDefs)
  result.add newIdentNode(name)
  var p = newNimNode(nnkPtrTy)
  p.add newIdentNode(kind)
  result.add p
  result.add newEmptyNode()

proc zifProc(prc: NimNode): NimNode {.compileTime.} =
  #echo ht
  #echo cast[int](returnValue)
  #echo cast[int](returnValuePtr)
  #echo cast[int](thisPtr)
  #echo retvalUsed

  if prc.kind notin {nnkProcDef, nnkLambda}:
      error("Cannot transform this node kind into an zip proc." &
            " Proc definition or lambda node expected.")

  result = newNimNode(nnkStmtList)

  var phpName = $prc[0].ident
  var zifName = "zif_" & phpName
  prc[0] = newIdentNode(zifName)

  var autoResult = prc[3][0]

  if not (autoResult.kind in {nnkEmpty, nnkIdent}):
    error("phpfunc proc needs a void return value")

  var body = newNimNode(nnkStmtList)

  if prc[3].len > 1:
    # we simulate real parameters (optional)
    var fmt = ""
    var args = ""
    var fixs: seq[string] = @[]
    var vargs = false
    for i in 1 ..< prc[3].len:
      let vname = $prc[3][i][0]
      let kind = $prc[3][i][1]
      #echo prc[3][i].lispRepr
      let default = prc[3][i][2].kind

      if default != nnkEmpty:
        # first time we have variable params we add the `|`
        if not vargs:
          fmt.add "|"
          vargs = true

      case kind:
        of "int":
          var tmp = "var " & vname & ": int"
          if default != nnkEmpty:
            tmp.add " = " & $prc[3][i][2].intVal
          body.add parseStmt tmp

          fmt.add "l"
          args.add ", " & vname & ".addr"

        of "bool":
          var tmp = "var " & vname & ": bool"
          if default != nnkEmpty:
            tmp.add " = " & $prc[3][i][2].ident
          body.add parseStmt tmp
          var help = "zifq" & $i & "_" & vname
          body.add parseStmt "var " & help & ": int8 = 123"
          fmt.add "b"
          args.add ", " & help & ".addr"
          # default values for bool are tricky to test for but this works
          fixs.add "if " & help & " != 123: " & vname & "=" & help & "!= 0"

        of "float":
          var tmp = "var " & vname & ": float64"
          if default != nnkEmpty:
            tmp.add " = " & $ prc[3][i][2].floatVal
          body.add parseStmt tmp
          fmt.add "d"
          args.add ", " & vname & ".addr"

        of "string":
          var help_s = "zifq" & $i & "s_" & vname
          var help_l = "zifq" & $i & "l_" & vname

          body.add parseStmt "var " & vname & ": string"
          body.add parseStmt "var " & help_s & ": cstring"
          body.add parseStmt "var " & help_l & ":ptr int64"
          fmt.add "s"
          args.add  ", " & help_s & ".addr, " & help_l & ".addr"
          # default values for strings are more expensive so we just
          # do them if needed
          if default != nnkEmpty:
            fixs.add "if " & help_s & " != nil: " & vname & "= $" & help_s & " else: " & vname & "=\"\"\"" & $prc[3][i][2].strVal & "\"\"\""
          else:
            fixs.add vname & "= $" & help_s
        else:
          error("Parameter Type '" & $kind & "' not supported")

    body.add parseStmt("discard zend_parse_parameters(ht, \"" & fmt & "\" " & args & ")")

    for fix in fixs:
      body.add parseStmt(fix)

  prc[3] = newNimNode(nnkFormalParams)
  prc[3].add copyNimNode(autoResult)

  prc[3].add newParam("ht","int")
  prc[3].add newParam("returnValue","ZVal")
  prc[3].add newPtrParam("returnValuePtr","ZVal")
  prc[3].add newParam("thisPtr","ZVal")
  prc[3].add newParam("retvalUsed","int")

  body.add prc[6]

  # works only for implicit returns (needs to scan body otherwise)
  if autoResult.kind == nnkIdent:
    case $autoResult.ident:
      of "int": body.add parseStmt("returnLong resukt")
      of "string": body.add parseStmt("returnString result")
      of "float": body.add parseStmt("returnFloat result")
      of "bool": body.add parseStmt("returnFloat bool")
      else: error "Automatic result type '" & $autoResult.ident & "' not supported"

  prc[6] = body

  result.add prc
  result.add parseStmt("zf.add(ZendFunctionEntry(fname: \"" & phpName & "\", handler: " & zifName & "))")

macro phpfunc*(prc: stmt): stmt {.immediate.} =
  # not sure about the nnkStmtList
  if prc.kind == nnkStmtList:
    error("phpfunc statement list?")
  else:
    result = zifProc(prc)

#
# THE MAGIC aka MODULE
#

var zf*: seq[ZendFunctionEntry] = @[]

var zm: ZendModuleEntry # global allocated!

proc get_module(): ptr ZendModuleEntry {.stdcall,exportc,dynlib.} =
  result = zm.addr

proc moduleStartup() {.stdcall.} =
  discard

proc moduleShutdown() {.stdcall.} =
  discard

proc requestStartup() {.stdcall.} =
  discard

proc requestShutdown() {.stdcall.} =
  discard

proc finishExtension*(name, version: string) =
  # build the Zend Module info
  zm.size = ZendModuleEntry.sizeof.uint16
  zm.zend_api = ZEND_MODULE_API_NO
  zm.zend_debug = 0
  zm.zts = 0
  zm.ini_entry = nil
  zm.deps = nil
  zm.name = name
  zm.version = version
  zm.build_id = "API" & $ZEND_MODULE_API_NO & ",NTS"

  zm.module_startup_func = moduleStartup
  zm.module_shutdown_func = moduleShutdown
  zm.request_startup_func = requestStartup
  zm.request_shutdown_func = requestShutdown

  zm.functions = zf[0].addr

  assert(zm.size==168)
