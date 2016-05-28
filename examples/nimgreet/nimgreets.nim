# nim build --verbosity:0
# run nim tests
# !run phpr dl("nimext.so"); dl("nimgreets.so"); echo nimgreeter(nim_alpha("12W!o#0&rl3_d?")).PHP_EOL;

import "../../src/nimzend.nim"

proc nimgreeter(s: string): string {.phpfunc.} =
  result = "Hello " & s & "!"

finishExtension("nimgreets", "0.1")
