# nim build --verbosity:0
# runphp dl("nimext.so"); echo nimfun(2.5, "Hello World!", " - ").PHP_EOL;

import nimzend
import math

#
# my code
#

proc nimfun(num: float, txt: string, sep: string = ",", tresh: float = 1.0, foo: int = 123, bar: bool = true) {.phpfunc.} =
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

finishExtension("nimext","0.1")
