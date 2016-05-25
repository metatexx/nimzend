# nim build --verbosity:0
# run nim tests
# !run phpr dl("nimext.so"); echo nim_zval("12\0"."3").PHP_EOL;
# !run phpr dl("nimext.so"); echo nim_alpha("12H!e#0&ll3_o?").PHP_EOL;
# !run phpr dl("nimext.so"); echo nim_fun(2.5, "Hello World!", " - ").PHP_EOL;

import "../../src/nimzend.nim"
import math

#
# my code
#

proc nim_fun(num: float, txt: string, sep: string = ",", tresh: float = 1.0, foo: int = 123, bar: bool = true) {.phpfunc.} =
  if notDiscarded:
    var r = ""
    var cnt = num.int
    # just for funr
    if num.floor() != num:
      r.add "*"

    if tresh > 0.5:
      r.add "+"

    for i in 0 ..< cnt:
      if i > 0: r.add sep
      r.add txt

    if bar:
      r.add $foo

    returnString(r)

proc nim_alpha(str: string): string {.phpfunc.} =
  result = ""
  for ch in str:
        if ch in {'a'..'z', 'A'..'Z'}:
          result.add ch

proc nim_zval(zv: ZVal) {.phpfunc.} =
  echo zv.kind
  echo zv.value.str.text
  echo zv.value.str.len

finishExtension("nimext","0.1")
