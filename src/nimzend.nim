# Minimal Zend Module

import macros

when defined(php503):
  const ZEND_MODULE_API_NO = 20090626
elif defined(php504):
  const ZEND_MODULE_API_NO = 20100525
elif defined(php505):
  const ZEND_MODULE_API_NO = 20121212
elif defined(php506):
  const ZEND_MODULE_API_NO = 20131226
elif defined(php700):
  const ZEND_MODULE_API_NO = 20151012
elif defined(nimcheck):
  const ZEND_MODULE_API_NO = 99999999
else:
  {.error:"You need to define the PHP version (php53 php54 php55 php56 php70).".}

when defined(php700):
  type
    ZendTypes* {.size: sizeof(uint8).} = enum
      IS_UNDEF
      IS_NULL
      IS_FALSE
      IS_TRUE
      IS_LONG
      IS_DOUBLE
      IS_STRING
      IS_ARRAY
      IS_OBJECT
      IS_RESOURCE
      IS_REFERENCE

    ZendTypeInfoV* = object
      kind: ZendTypes
      flags: uint8
      gc_info: uint16

    ZendTypeInfoFlags* = enum
      IS_STR_PERSISTENT = 1 # allocated using malloc
      IS_STR_INTERNED = 2   # interned string
      IS_STR_PERMANENT = 4  # interned string surviving request boundary

    ZendTypeInfoUnion* = object {.union.}
      type_info: uint32
      v: ZendTypeInfoV

    ZendRefcountedObj* = object
      refcount: uint32
      u: ZendTypeInfoUnion

    ZendStringObj* = object
      gc: ZendRefcountedObj
      h: uint64 # string hash
      len: int64
      val: array[0..0, char]

    ZendString = ptr ZendStringObj

    ZendBucketObj* = object
      val: ZValObj
      h:  uint64            # hash value (or numeric index)
      key: ZendString       # string key or NULL for numerics

    ZendBucket* = ptr ZendBucketObj

    ZendArrayV* = object
      flags: uint8
      nApplyCount: uint8
      nIteratorsCound: uint8
      reserve: uint8

    ZendArrayU* = object {.union.}
      v: ZendArrayV
      flags: uint32

    ZendArrayObj* = object
      gc: ZendRefcountedObj
      u: ZendArrayU
      nTableMask: uint32
      arData: ZendBucket
      nNumUsed: uint32
      nNumOfElements: uint32
      nTableSize: uint32
      nInternalPointer: uint32
      nNextFreeElement: int64
      pDestructor: pointer  # dtor_func_t

    ZendArray* = ptr ZendArrayObj

    ZendObjectObj = object # dummy

    ZendObject = ptr ZendObjectObj

    ZendValue* = object {.union.}
      lval: int64
      dval: float64
      counted: ptr ZendRefcountedObj
      str: ZendString
      arr: ZendArray
      obj: ZendObject
      `ref`: pointer
      ast: pointer

      zv: ZVal
      `ptr`: pointer
      ww: tuple[w1: uint32, w2: uint32]

    ZValV* = object {.packed.}
      kind: ZendTypes
      kind_flags: uint8
      const_flags: uint8
      reserved: uint8

    ZValU1Types* = enum
      IS_TYPE_CONSTANT = 1
      IS_TYPE_IMMUTABLE = 2
      IS_TYPE_REFCOUNTED = 4
      IS_TYPE_COLLECTABLE = 8
      IS_TYPE_COPYABLE = 16
      IS_TYPE_SYMBOLTABLE = 32

    ZValU1* = object {.union.}
      v: ZValV
      type_info: uint32

    ZValU2* = object {.union.}
      var_flags: uint32
      next: uint32        # hash collision chain
      cache_slot: uint32   # literal cache slot
      lineno: uint32      # line number (for ast nodes)
      num_args: uint32    # arguments number for EX(this)
      fe_pos: uint32      # foreach position
      fe_iter_idx: uint32 # foreach iterator index

    ZValObj* = object
      value: ZendValue
      u1: ZValU1
      u2: ZValU2

    ZVal* = ptr ZValObj

    ZendExecuteDataObj* = object
      opline: pointer #const / executed opline
      call: ptr ZendExecuteDataObj # current call
      return_value: ZVal
      fn: pointer #zend_function *func; # executed function
      this: ZValObj # /* this + call_info + num_args
      prev_execute_data: ptr ZendExecuteDataObj
      symbol_table: ptr ZendArrayObj

    ZendExecuteData* = ptr ZendExecuteDataObj

else:
  type
    ZendTypes* {.size: sizeof(uint8).} = enum
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

    ZendStringObj* = object
      text: cstring
      len: int64

    ZendString* = ptr ZendStringObj

    ZendValue* = object {.union.}
      long: int64
      dval: float64
      str: tuple[text: cstring, len: int64]
      arr: ZendArray

    ZendBucketObj* = object
      val: ZValObj
      h:  uint64            # hash value (or numeric index)
      key: ZendString       # string key or NULL for numerics

    ZendBucket* = ptr ZendBucketObj

    ZendArrayObj* = object
      nTableSize: uint32
      nTableMask: uint32
      nNumOfElements: uint32
      nNextFreeElement: int64
      pInternalPointer: ZendBucket # used for element traversal
      pListHead: ZendBucket
      pListTail: ZendBucket
      arBuckets: ptr ZendBucket
      pDestructor: pointer  # dtor_func_t
      persistend: bool # unsure about sizeof's from here
      nApplyCount: uint8
      bApplyProtection: bool

    ZendArray* = ptr ZendArrayObj

    ZValObj* = object
      value: ZendValue
      refcountGC: uint32
      kind: ZendTypes
      isRefGc: uint8

    ZVal* = ptr ZValObj

    #ZendExecuteDataObj* = object
    #ZendExecuteData* = ptr ZendExecuteDataObj

# pseudo types for parameters

type
  ZValArray* = distinct ZVal
  ZValArrayS* = ZValArray

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

# zend functions

proc zend_parse_parameters*(num: int, format: cstring): int {.importc: "zend_parse_parameters", varargs.}

proc zend_malloc*(size: int): pointer {.importc:"malloc".}
proc zend_free*(size: int): pointer {.importc:"free".}

proc php_printf*(format: cstring) {.importc:"php_printf", varargs.}
proc zvalType*(arg: ZVal): cstring {.stdcall,importc:"zend_zval_type_name".}

proc emalloc*(size: int): pointer {.importc:"_emalloc".}
proc efree*(mem: pointer) {.importc:"_efree".}
proc estrdup*(txt: cstring): cstring {.importc:"_estrdup".}

proc zend_hash_func*(str: cstring, len: int64): uint64 {.importc:"zend_hash_func".}

# ZendArray
proc array_init*(arg: ZValArray, size: uint32 = 0): int {.discardable,importc:"_array_init".}

proc add_assoc_long*(arg: ZValArray, key: cstring, key_len: int, n: int64): int {.discardable,importc:"add_assoc_long_ex".}
proc add_assoc_double*(arg: ZValArray, key: cstring, key_len: int, n: float64): int {.discardable,importc:"add_assoc_double_ex".}
proc add_assoc_bool*(arg: ZValArray, key: cstring, key_len: int, n: bool): int {.discardable,importc:"add_assoc_bool_ex".}
proc add_assoc_null*(arg: ZValArray, key: cstring, key_len: int): int {.discardable,importc:"add_assoc_null_ex".}
proc add_assoc_string*(arg: ZValArray, key: cstring, key_len: int, str: cstring): int {.discardable,importc:"add_assoc_string_ex".}
proc add_assoc_stringl*(arg: ZValArray, key: cstring, key_len: int, str: cstring, len: int): int {.discardable,importc:"add_assoc_stringl_ex".}
proc add_assoc_zval*(arg: ZValArray, key: cstring, key_len: int, val: ZVal): int {.discardable,importc:"add_assoc_zval_ex".}

proc add_index_long*(arg: ZValArray, idx: uint64, n: int64): int {.discardable,importc:"add_index_long".}
proc add_index_bool*(arg: ZValArray, idx: uint64, n: bool): int {.discardable,importc:"add_index_bool".}
proc add_index_double*(arg: ZValArray, idx: uint64, n: float64): int {.discardable,importc:"add_index_double".}
proc add_index_null*(arg: ZValArray, idx: uint64): int {.discardable,importc:"add_index_null".}
proc add_index_string*(arg: ZValArray, idx: uint64, str: cstring): int {.discardable,importc:"add_index_string".}
proc add_index_stringl*(arg: ZValArray, idx: uint64, str: cstring, len: int): int {.discardable,importc:"add_index_stringl".}
proc add_index_zval*(arg: ZValArray, idx: uint64, str: ZVal): int {.discardable,importc:"add_index_zval".}

proc add_next_index_long*(arg: ZValArray, n: int64): int {.discardable,importc:"add_next_index_long".}
proc add_next_index_double*(arg: ZValArray, n: float64): int {.discardable,importc:"add_next_index_double".}
proc add_next_index_bool*(arg: ZValArray, n: bool): int {.discardable,importc:"add_next_index_bool".}
proc add_next_index_null*(arg: ZValArray): int {.importc:"add_next_index_null".}
proc add_next_index_string*(arg: ZValArray, str: cstring): int {.discardable,importc:"add_next_index_string".}
proc add_next_index_stringl*(arg: ZValArray, str: cstring, len: int): int {.discardable,importc:"add_next_index_stringl".}
proc add_next_index_zval*(arg: ZValArray, str: ZVal): int {.discardable,importc:"add_next_index_zval".}

when defined(php70):
  proc zend_array_count*(arg: ZendArray): uint32 {.importc:"zend_array_count".}
  template zend_hash_num_elements*(arg: ZendArray): uint32 = (arg).nNumOfElements
  template klen*(k: string): int = k.len
else:
  proc zend_hash_num_elements*(arg: ZendArray): uint32 {.importc:"zend_hash_num_elements".}
  template zend_array_count*(arg: ZendArray): uint32 = zend_hash_num_elements(arg)
  # PHP 5.x needs key.len + 1 for the assoc functions
  template klen*(k: string): int = k.len + 1

proc len*(zv: ZValArray): int = zend_array_count(zv.ZVal.value.arr).int

template pemalloc*(size: int, persistent: bool): pointer =
  if persistent: zend_malloc(size) else: emalloc(size)

const eightint = sizeof(int) * 8

template ZendMMAlignment*(s: int): int =
  (((s) + eightint) and not (eightint - 1))

#echo ZendMMAlignment(65)

proc createZVal*(): ZVal =
  cast[ZVal](emalloc(sizeof(ZValObj)))

when defined(php700):
  template notDiscarded*(): bool =
    true # for now

  template zendStringInit(s: string, persistent: bool = false): ZendString =
    zendStringInit(s, s.len, persistent)

  proc zendStringInit(s: string, len: int, persistent: bool = false): ZendString =
    result = cast[ZendString](pemalloc(ZendMMAlignment(len + sizeof(ZendStringObj)), persistent))
    copyMem(result.val[0].addr,s.cstring,len)
    cast[ptr char](cast[int](result.val[0].addr)+len+1)[]='\0'
    result.len = s.len
    result.gc.refcount = 0
    result.gc.u.v.kind = IS_STRING
    result.h = zend_hash_func(result.val[0].addr, result.len)
    if persistent:
      result.gc.u.v.flags = IS_STR_PERSISTENT.uint8
    else:
      result.gc.u.type_info = IS_TYPE_REFCOUNTED.uint32 + IS_TYPE_COPYABLE.uint32

  # Our Functions
  proc zvalString*(v: ZVal, s: string, n: int = 0, persistent: bool = false) {.inline.} =
    v.value.str = zendStringInit(s, persistent)
    v.u1.v.kind = IS_STRING
    v.u1.v.kind_flags = v.value.str.gc.u.v.flags

  proc zvalLong*(z: ZVal, v: int64) {.inline.} =
    z.value.lval = v
    z.u1.v.kind = IS_LONG

  proc zvalFloat*(z: ZVal, v: float64) {.inline.} =
    z.value.dval = v
    z.u1.v.kind = IS_DOUBLE

  #proc allocZendArray(v: ZVal) =
    #v.value.arr = cast[ZendArray](emalloc(sizeof(ZendArrayObj)))
    #v.u1.v.kind = IS_ARRAY
    #v.u1.v.kind_flags = IS_TYPE_REFCOUNTED.uint8 + IS_TYPE_COLLECTABLE.uint8 + IS_TYPE_COPYABLE.uint8

  template returnArray*() =
    discard zend_array_init(returnValue,0)
    #let key1 = "key1"
    #discard zend_add_assoc_long_ex(v, key1, key1.len, 12345)
    #let key2 = "key2"
    #discard zend_add_assoc_string_ex(v, key2, key2.len, "Cool!")
    #let key3 = "key3"
    #discard zend_add_assoc_stringl_ex(v, key3, key3.len, "Cool!", 2)
    #discard zend_add_index_long(v, 0, 4711)
    return

else:
  template notDiscarded*(): bool =
    (retval_used == 1)

  proc zvalString*(v: ZVal, s: string, persistent: bool = false) {.inline.} =
    v.value.str.text = estrdup(s)
    v.value.str.len = s.len
    v.kind = IS_STRING

  proc zvalLong*(z: ZVal, v: int64) =
    z.value.long = v
    z.kind = IS_LONG

  proc zvalFloat*(z: ZVal, v: float64) =
    z.value.dval = v
    z.kind = IS_DOUBLE

proc zvalArray*(size: uint32 = 0): ZValArray =
  result = createZVal().ZValArray
  discard result.array_init(size)

proc zvalLong*(val: int): ZVal =
  result = createZVal()
  result.zvalLong(val)

proc zvalFloat*(val: float): ZVal =
  result = createZVal()
  result.zvalFloat(val)

proc zvalString*(val: string): ZVal =
  result = createZVal()
  result.zvalString(val)

template returnString*(s) =
  zvalString(returnValue, s)
  return

template returnLong*(s) =
  zvalLong(returnValue, s)
  return

template returnFloat*(s) =
  zvalFloat(returnValue, s)
  return

converter zvalFromZValArray*(val: ZValArray): ZVal = val.ZVal

type NULLType* = distinct pointer
const NULL* = nil.NULLType

proc add*(arr: ZValArray, val: int64) =
  discard arr.add_next_index_long(val)

# xxx how to allow add nil (and just that)?
proc addNull*(arr: ZValArray, dummy: NULLType) =
  discard arr.add_next_index_null()

proc add*(arr: ZValArray, val: float64) =
  discard arr.add_next_index_double(val)

proc add*(arr: ZValArray, val: bool) =
  discard arr.add_next_index_bool(val)

proc add*(arr: ZValArray, val: string) =
  discard arr.add_next_index_string(val)

proc add*(arr: ZValArray, val: ZVal) =
  discard arr.add_next_index_zval(val)

proc `[]=`*(arr: ZValArray, idx: uint32, val: int64) =
  discard arr.add_index_long(idx, val)

proc `[]=`*(arr: ZValArray, idx: uint32, val: float64) =
  discard arr.add_index_double(idx, val)

proc `[]=`*(arr: ZValArray, idx: uint32, val: bool) =
  discard arr.add_index_bool(idx, val)

proc `[]=`*(arr: ZValArray, idx: uint32, dummy: NULLType) =
  discard arr.add_index_null(idx)

proc `[]=`*(arr: ZValArray, idx: uint32, val: string) =
  discard arr.add_index_string(idx, val)

proc `[]=`*(arr: ZValArray, idx: uint32, val: ZVal) =
  discard arr.add_index_zval(idx, val)

proc `[]=`*(arr: ZValArray, key: string, len: int, val: int64) =
  discard arr.add_assoc_long(key, len, val)

proc `[]=`*(arr: ZValArray, key: string, val: int64) =
  `[]=`(arr, key, key.klen, val)

proc `[]=`*(arr: ZValArray, key: string, len: int, val: float64) =
  discard arr.add_assoc_double(key, len, val)

proc `[]=`*(arr: ZValArray, key: string, val: float64) =
  `[]=`(arr, key, key.klen, val)

proc `[]=`*(arr: ZValArray, key: string, len: int, val: bool) =
  discard arr.add_assoc_bool(key, len, val)

proc `[]=`*(arr: ZValArray, key: string, val: bool) =
  `[]=`(arr, key, key.klen, val)

proc `[]=`*(arr: ZValArray, key: string, len: int, dummy: NULLType) =
  discard arr.add_assoc_null(key, len)

proc `[]=`*(arr: ZValArray, key: string, dummy: NULLType) =
  `[]=`(arr, key, key.klen, dummy)

proc `[]=`*(arr: ZValArray, key: string, len: int, val: string) =
  discard arr.add_assoc_string(key, len, val)

proc `[]=`*(arr: ZValArray, key: string, val: string) =
  `[]=`(arr, key, key.klen, val)

proc `[]=`*(arr: ZValArray, key: string, len: int, val: ZVal) =
  discard arr.add_assoc_zval(key, len, val)

proc `[]=`*(arr: ZValArray, key: string, val: ZVal) =
  `[]=`(arr, key, key.klen, val)

# The macro magic for module creation

proc newParam(name: string, kind: string): NimNode {.compiletime.} =
  result = newNimNode(nnkIdentDefs)
  result.add newIdentNode(name)
  result.add newIdentNode(kind)
  result.add newEmptyNode()

when not defined(php700):
  proc newPtrParam(name: string, kind: string): NimNode {.compiletime.} =
    result = newNimNode(nnkIdentDefs)
    result.add newIdentNode(name)
    var p = newNimNode(nnkPtrTy)
    p.add newIdentNode(kind)
    result.add p
    result.add newEmptyNode()

var
  regs {.compileTime.}: NimNode

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

  if autoResult.kind notin {nnkEmpty, nnkIdent}:
    error("phpfunc proc needs a void return value but is " & autoResult.lispRepr)

  var body = newNimNode(nnkStmtList)

  if autoResult.kind == nnkIdent:
    case $autoResult.ident:
      of "ZValArray":
        body.add parseStmt("var result = returnValue.ZValArray")
        body.add parseStmt("discard result.array_init")
        autoResult = newEmptyNode()
        prc[3][0] = autoResult
      of "ZVal":
        body.add parseStmt("var result = returnValue")
        autoResult = newEmptyNode()
        prc[3][0] = autoResult
      else: discard

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
        of "ZVal":
          var tmp = "var " & vname & ": ZVal"
          if default != nnkEmpty:
            error("Default parameters for ZVal not possible")
          body.add parseStmt tmp

          fmt.add "z"
          args.add ", " & vname & ".addr"

        of "ZValArrayS":
          var tmp = "var " & vname & ": ZValArray"
          if default != nnkEmpty:
            error("Default parameters for Array not implemented")
          body.add parseStmt tmp

          fmt.add "a/"
          args.add ", " & vname & ".addr"

        of "ZValArray":
          var tmp = "var " & vname & ": ZValArray"
          if default != nnkEmpty:
            error("Default parameters for Array not implemented")
          body.add parseStmt tmp

          fmt.add "a"
          args.add ", " & vname & ".addr"

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

          body.add parseStmt "var " & vname & ":string"
          body.add parseStmt "var " & help_s & ":cstring"
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

    when defined(php700):
      body.add parseStmt("discard zend_parse_parameters(execute_data.this.u2.numArgs.int, \"" & fmt & "\" " & args & ")")
    else:
      body.add parseStmt("discard zend_parse_parameters(ht, \"" & fmt & "\" " & args & ")")

    for fix in fixs:
      body.add parseStmt(fix)

  prc[3] = newNimNode(nnkFormalParams)
  prc[3].add copyNimNode(autoResult)

  when defined(php700):
    prc[3].add newParam("execute_data","ZendExecuteData")
    prc[3].add newParam("returnValue","ZVal")
  else:
    prc[3].add newParam("ht","int")
    prc[3].add newParam("returnValue","ZVal")
    prc[3].add newPtrParam("returnValuePtr","ZVal")
    prc[3].add newParam("thisPtr","ZVal")
    prc[3].add newParam("retvalUsed","int")

  body.add prc[6]

  # works only for implicit returns (needs to scan body otherwise)
  if autoResult.kind == nnkIdent:
    case $autoResult.ident:
      of "int": body.add parseStmt("returnLong result")
      of "string": body.add parseStmt("returnString result")
      of "float": body.add parseStmt("returnFloat result")
      of "bool": body.add parseStmt("returnBool result")
      else: error "Automatic result type '" & $autoResult.ident & "' not supported"

  prc[6] = body

  result.add prc
  if regs == nil: regs = newNimNode(nnkBracket)
  template entry(a, b) =
    ZendFunctionEntry(fname: a, handler: b)
  regs.add(getAst(entry(newLit(phpName), newIdentNode zifName)))
  #result.add parseStmt("zf.add(ZendFunctionEntry(fname: \"" & phpName & "\", handler: " & zifName & "))")

macro phpfunc*(prc: untyped): untyped {.immediate.} =
  # not sure about the nnkStmtList
  if prc.kind == nnkStmtList:
    error("phpfunc statement list?")
  else:
    result = zifProc(prc)

#
# THE MAGIC aka MODULE
#

#proc NimMainInit() {.importc.}

proc moduleStartup() {.stdcall.} =
  discard

proc moduleShutdown() {.stdcall.} =
  discard

proc requestStartup() {.stdcall.} =
  discard

proc requestShutdown() {.stdcall.} =
  when defined(gcstack):
    deallocAll()
  else:
    discard

macro funcArray(): untyped =
  template entry(a, b) =
    ZendFunctionEntry(fname: a, handler: b)
  regs.add(getAst(entry(newNimNode(nnkNilLit), newNimNode(nnkNilLit))))
  template fa(x) =
    var funca {.global.} = x
    unsafeAddr(funca[0])
  result = getAst(fa(regs))
  #echo repr result

template finishExtension*(extname, extversion: string) =
  # build the Zend Module info
  var zm {.global.}: ZendModuleEntry

  proc get_module(): ptr ZendModuleEntry {.stdcall,exportc,dynlib.} =
    result = zm.addr

  zm.size = ZendModuleEntry.sizeof.uint16
  zm.zend_api = ZEND_MODULE_API_NO
  zm.zend_debug = 0
  zm.zts = 0
  zm.ini_entry = nil
  zm.deps = nil
  zm.name = extname
  zm.version = extversion
  zm.build_id = "API" & $ZEND_MODULE_API_NO & ",NTS"

  zm.module_startup_func = moduleStartup
  zm.module_shutdown_func = moduleShutdown
  zm.request_startup_func = requestStartup
  zm.request_shutdown_func = requestShutdown

  zm.functions = funcArray()

  assert(zm.size==168)
