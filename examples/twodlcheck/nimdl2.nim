# nim nop
# run nim build --verbosity:0 nimdl1.nim
# run nim build --verbosity:0 nimdl2.nim
# run phpr @dl("nimdl1.so"); @dl("nimdl2.so"); echo var_dump(dl1(1)).dl2("test=#id","foo").PHP_EOL;

import "../../src/nimzend.nim"

import pegs

proc dl2(s: string, r: string) {.phpfunc.} =
  let p2 = peg"'#id'"
  returnString s.replace(p2,"'" & r & "'")

finishExtension("nimdl2", "0.1")
