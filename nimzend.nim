# nim build nimext
## nim c --app:lib --d:php54-d:release -l:"-undefined suppress -flat_namespace" -o:../nimzend.so --verbosity:0
## runphp dl("nimzend.so"); $a=4711; echo nim(1234).' '.substr(nim(-1),0,40);

# Minimal Zend Module
import macros
import strutils

when defined(php504):
  const ZEND_MODULE_API_NO = 20100525
elif defined(php503):
  const ZEND_MODULE_API_NO = 20090626
else:
  const ZEND_MODULE_API_NO = 20090626
  {.error:"You need to define the PHP version (php54 php53)".}

type
  ZendModuleEntry* = object # not {.packed.} !
    size: uint16
    zend_api: uint32
    zend_debug: uint8
    zts: uint8
    init_entry: pointer #const struct _zend_ini_entry *ini_entry;
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

proc zend_parse_parameters*(num: int, format: cstring, p1,p2,p3,p4,p5,p6,p7,p8: pointer): int {.importc: "zend_parse_parameters".}

proc pmalloc*(size: int): pointer {.importc:"_emalloc".}
proc pfree*(mem: pointer) {.importc:"_efree".}
proc pstrdup*(txt: cstring): cstring {.importc:"_estrdup".}

# Our Functions

template returnString*(s) =
  returnValue.value.str.text = pstrdup(s)
  returnValue.value.str.len = s.len
  returnValue.kind = IS_STRING
  return

template returnLong*(s) =
  returnValue.value.long = s
  returnValue.kind = IS_LONG
  return

template notDiscarded*(): bool =
  (retval_used == 1)

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

  if prc[3][0].kind != nnkEmpty:
    error("phpfunc proc needs a void return value")

  var body = newNimNode(nnkStmtList)

  if prc[3].len > 1:
    # declaration of "ref" variables
    for i in 1 ..< prc[3].len:
      let vname = $prc[3][i][0]
      let kind = $prc[3][i][1]
      #let vref = (prc[3][i][2].kind == nnkEmpty)
      case kind:
        of "int": body.add parseStmt("(var " & vname & ": int;" &
          "discard zend_parse_parameters(ht, \"l\", " & vname & ".addr, nil, nil, nil, nil, nil, nil, nil))")
        of "int8": body.add parseStmt("(var " & vname & ": int8;" &
          "var l: int; discard zend_parse_parameters_int(ht, \"l\", l.addr, nil, nil, nil, nil, nil, nil, nil); " & vname & "=l.int8)")
        of "string": body.add parseStmt("(var " & vname & ": string;" &
          "var ip_s: cstring; var ip_l: int; discard zend_parse_parameters(ht, \"s\", ip_s.addr, ip_l.addr, nil, nil, nil, nil, nil, nil); " & vname & " = $ip_s)")
        else: error("parameter type not supported")

  prc[3] = newNimNode(nnkFormalParams)
  prc[3].add newEmptyNode()

  var n = newNimNode(nnkIdentDefs)
  n.add newIdentNode("ht")
  n.add newIdentNode("int")
  n.add newEmptyNode()
  prc[3].add n

  n = newNimNode(nnkIdentDefs)
  n.add newIdentNode("returnValue")
  n.add newIdentNode("ZVal")
  n.add newEmptyNode()
  prc[3].add n

  n = newNimNode(nnkIdentDefs)
  n.add newIdentNode("returnValuePtr")
  var p = newNimNode(nnkPtrTy)
  p.add newIdentNode("ZVal")
  n.add p
  n.add newEmptyNode()
  prc[3].add n

  n = newNimNode(nnkIdentDefs)
  n.add newIdentNode("thisPtr")
  n.add newIdentNode("ZVal")
  n.add newEmptyNode()
  prc[3].add n

  n = newNimNode(nnkIdentDefs)
  n.add newIdentNode("retvalUsed")
  n.add newIdentNode("int")
  n.add newEmptyNode()
  prc[3].add n

  body.add prc[6]
  prc[6] = body

  result.add prc
  result.add parseStmt("zf.add(ZendFunctionEntry(fname: \"$1\", handler: $2))".format(phpName,zifName))

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
var zm*: ZendModuleEntry # global allocated!

proc get_module*(): ptr ZendModuleEntry {.stdcall,exportc,dynlib.} =
  result = zm.addr

proc finishExtension*(name, version: string) =
  # build the Zend Module info
  zm.size = ZendModuleEntry.sizeof.uint16
  zm.zend_api = ZEND_MODULE_API_NO
  zm.zend_debug = 0
  zm.zts = 0
  zm.init_entry = nil
  zm.deps = nil
  zm.name = name
  zm.version = version
  zm.build_id = "API" & $ZEND_MODULE_API_NO & ",NTS"

  zm.functions = zf[0].addr

  assert(zm.size==168)
