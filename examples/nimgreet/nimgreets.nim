# nim build --verbosity:0
# run nim tests

import "../../src/nimzend.nim"

proc nimgreeter(s: string) {.phpfunc.} =
  returnString "Hello " & s & "!"

finishExtension("nimgreets", "0.1")
