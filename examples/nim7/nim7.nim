# nim build -d:php54 -d:phpinfo --verbosity:1 --hints:off
# run nim tests -d:php54
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

  phpPrintf("The %s has %d elements!\n", zva.zvalType, zva.len)

  let key0 = "key0"
  add_assoc_null(v, key0, key0.klen) # php 5 / php 7 use different lens!
  let key1 = "key1"
  add_assoc_long(v, key1, key1.klen, 12345)
  let key2 = "key2"
  add_assoc_string(v, key2, key2.klen, "Cool!")
  let key3 = "key3"
  add_assoc_stringl(v, key3, key3.klen, "Cool!", 2)

  add_index_null(v, 0)
  add_index_long(v, 1, 4711)
  add_index_string(v, 2, "Foo!")
  add_index_stringl(v, 3, "Barbapapa", 3)

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
