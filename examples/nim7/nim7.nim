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

proc nim_arr(zva: ZValArray): ZValArray {.phpfunc.} =
  let v = result

  echo "Array Elements: ", zva.len

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

  var zv1 = zvalLong(1234567890)
  v[4] = zv1
  v[5] = zvalString("Test ZVal")
  v[6] = 9876543210
  # skipping 7
  v[8] = "String direct"
  v[9] = NULL # niltest

  # using zva here only works in php 7 .. why?
  #discard add_index_zval(v, 6, zva)

  var zs3 = zvalArray()
  zs3.add 100
  zs3.add "101x"
  zs3.add 102.1

  v.add zs3

  var zs4 = zvalArray()
  zs4["name"] = "Nim"
  zs4["age"] = 3500
  zs4["salary"] = 1.75

  v.add zs4

finishExtension("nim7","0.1")
