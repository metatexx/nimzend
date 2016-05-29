# nim nop
# run nim build --verbosity:0 nimdl1.nim
# run nim build --verbosity:0 nimdl2.nim
# run nim tests
# run phpr @dl("nimdl1.so"); @dl("nimdl2.so"); echo var_dump(dl1(1)).dl2("test=#id","foo").PHP_EOL;

import "../../src/nimzend.nim"

proc dl1(s2: string): ZValArray {.phpfunc.} = result.add s2

finishExtension("nimdl1", "0.1")
