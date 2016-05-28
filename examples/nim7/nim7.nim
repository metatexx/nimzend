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

proc nim_arr(s: ZValArray) {.phpfunc.} =
  let v = returnValue.ZValArray
  discard array_init(v,0)

  echo s[].repr

  let key0 = "key0"
  discard add_assoc_null(v, key0, key0.len)
  let key1 = "key1"
  discard add_assoc_long(v, key1, key1.len, 12345)
  let key2 = "key2"
  discard add_assoc_string(v, key2, key2.len, "Cool!")
  let key3 = "key3"
  discard add_assoc_stringl(v, key3, key3.len, "Cool!", 2)

  discard add_index_null(v, 0)
  discard add_index_long(v, 1, 4711)
  discard add_index_string(v, 2, "Foo!")
  discard add_index_stringl(v, 3, "Barbapapa", 3)

  var zv1 = createZVal()
  zv1.zvalLong(1234)
  discard add_index_zval(v, 4, zv1)

  var zv2 = createZVal()
  zvalZendString(zv2, "Test ZVal")
  discard add_index_zval(v, 5, zv2)

  # using s here only works in php 7 .. why?
  #discard add_index_zval(v, 6, s)

  var zs3 = createZVal().ZValArray
  discard zs3.array_init(0)
  discard zs3.add_next_index_long(1)
  discard zs3.add_next_index_long(2)
  discard zs3.add_next_index_long(3)
  discard add_next_index_zval(v, zs3.ZVal)

  #returnArray()

finishExtension("nim7","0.1")
