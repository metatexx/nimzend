# nim nop
# run nim build --verbosity:0 nimdl1.nim
# run nim build --verbosity:0 nimdl2.nim
# run phpr @dl("nimdl1.so"); @dl("nimdl2.so"); echo dl1(1).dl2().PHP_EOL;

import "../../src/nimzend.nim"

import pegs

proc dl2() {.phpfunc.} =
  let p2 = peg"'test'"
  returnString p2.repr

finishExtension("nimdl2", "0.1")
