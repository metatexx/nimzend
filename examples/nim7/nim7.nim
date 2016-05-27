# nim build -d:phpinfo --verbosity:1 --hints:off
# run nim tests
# !run php7r dl("nim7.so"); echo ">".nim_say("World")."<".PHP_EOL;
# !run php7r dl("nim7.so"); echo ">".nim_add(123, 111)."<".PHP_EOL;

import "../../src/nimzend.nim"

#
# my code
#

proc nim_add(a: int, b: int): int {.phpfunc.} =
  result = a + b

proc nim_say(s: string) {.phpfunc.} =
  returnString("Hello " & s & "!")

finishExtension("nim7","0.1")
