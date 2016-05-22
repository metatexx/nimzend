# nim build --verbosity:0
# php greeter.php

import "../../src/nimzend.nim"

proc nimgreeter(s: string) {.phpfunc.} =
  returnString "Hello " & s & "!"

finishExtension("nimgreets", "0.1")
