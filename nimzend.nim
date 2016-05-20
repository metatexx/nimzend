# nim c --app:lib --d:phpext -d:release -l:"-undefined suppress -flat_namespace" -o:../nimzend.so --verbosity:0
# runphp dl("nimzend.so"); $a=4711; echo nim(1234).' '.substr(nim(-1),0,40);

# Minimal Zend Module
import macros

when not defined(phpext):
  when defined(release):
    {.error: "need --d:phpext in commandline".}

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

const ZEND_MODULE_API_NO = 20100525

# zend functions

proc zend_zval_type_name*(arg: ZVal): cstring {.stdcall,importc.}

proc zend_parse_parameters*(num: int, format: cstring, data: ptr int): int {.importc.}

proc pmalloc*(size: int): pointer {.importc:"_emalloc".}
proc pfree*(mem: pointer) {.importc:"_efree".}
proc pstrdup*(txt: cstring): cstring {.importc:"_estrdup".}

# Our Functions

template return_string*(s) =
  returnValue.value.str.text = pstrdup(s)
  returnValue.value.str.len = s.len
  returnValue.kind = IS_STRING
  return

template return_long*(s) =
  returnValue.value.long = s
  returnValue.kind = IS_LONG
  return

template notDiscarded*(): bool =
  (retval_used == 1)

proc zifProc(prc: NimNode): NimNode {.compileTime.} =
  ## This macro makes all parameter lazy by transforming them to proc calls

  #echo ht
  #echo cast[int](returnValue)
  #echo cast[int](returnValuePtr)
  #echo cast[int](thisPtr)
  #echo retvalUsed

  if prc.kind notin {nnkProcDef, nnkLambda}:
      error("Cannot transform this node kind into an zip proc." &
            " Proc definition or lambda node expected.")

  result = newNimNode(nnkStmtList)

  prc[0] = newIdentNode("zif_" & $prc[0].ident)

  if prc[3][0].kind != nnkEmpty:
    error("phpfunc proc needs a void return value")

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

  result.add prc
  result.add parseStmt("""zf.add(ZendFunctionEntry(fname: "nim", handler: zif_nim))""")

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
