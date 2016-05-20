# nim build --verbosity:0
# runphp dl("nimext.so"); echo nimgreets("Hello World!").PHP_EOL; echo nimsqr(9).PHP_EOL;

import nimzend

#
# my code
#

proc nimgreets(s: string) {.phpfunc.} =
  if notDiscarded:
    returnString(s)

proc nimsqr(n: int) {.phpfunc.} =
  if notDiscarded:
    returnLong(n * n)

finishExtension("nimext","0.1")
