# nim nop
# run nim build --verbosity:0 nimdl1.nim
# run nim build --verbosity:0 nimdl2.nim
# run phpr @dl("nimdl2.so"); @dl("nimdl1.so"); echo dl1(1).dl2().PHP_EOL;

import "../../src/nimzend.nim"

proc dl1(s2: string): string {.phpfunc.} =
  result = s2

finishExtension("nimdl1", "0.1")
