# nim build -d:php70 -d:phpinfo --verbosity:1 --hints:off
# run nim tests -d:php70
# !run php7r dl("nim7.so"); echo ">".nim_say("World")."<".PHP_EOL;
# !run php7r dl("nim7.so"); echo ">".nim_add(123, 111)."<".PHP_EOL;

import "../../src/nimzend.nim"

#
# my code
#

proc nim_add(a: int, b: int): int {.phpfunc.} =
  result = a + b

proc nim_say(s: string): string {.phpfunc.} =
  result = "Hello " & s & "!"

proc nim_arr(s: ZVal) {.phpfunc.} =
  let v = returnValue
  discard zend_array_init(v,0)

  let key0 = "key0"
  discard zend_add_assoc_null(v, key0, key0.len)
  let key1 = "key1"
  discard zend_add_assoc_long(v, key1, key1.len, 12345)
  let key2 = "key2"
  discard zend_add_assoc_string(v, key2, key2.len, "Cool!")
  let key3 = "key3"
  discard zend_add_assoc_stringl(v, key3, key3.len, "Cool!", 2)

  discard zend_add_index_null(v, 0)
  discard zend_add_index_long(v, 1, 4711)
  discard zend_add_index_string(v, 2, "Foo!")
  discard zend_add_index_stringl(v, 3, "Barbapapa", 3)

  #discard zend_add_index_str(v, 4, s)

  var zs1 = createZVal()
  zs1.zvalLong(1234)
  discard zend_add_index_zval(v, 4, zs1)

  var zs2 = createZVal()
  zvalZendString(zs2, "TestVZal")
  discard zend_add_index_zval(v, 5, zs2)

  discard zend_add_index_zval(v, 6, s)

  #returnArray()

finishExtension("nim7","0.1")
