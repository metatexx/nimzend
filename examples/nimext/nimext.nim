# nim build --verbosity:0
# runphp dl("nimext.so"); echo nim_alpha("12H!e#0&ll3_o?").PHP_EOL;
# runphp dl("nimext.so"); echo nim_fun(2.5, "Hello World!", " - ").PHP_EOL;

import nimzend
import math

#
# my code
#

proc nim_fun(num: float, txt: string, sep: string = ",", tresh: float = 1.0, foo: int = 123, bar: bool = true) {.phpfunc.} =
  if notDiscarded:
    var r = ""
    var cnt = num.int
    # just for fun
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


finishExtension("nimext","0.1")
