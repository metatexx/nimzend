# nim build -d:php70 --verbosity:0 --hints:off
# run nim tests -d:php70
# !run php7r dl("nim7.so"); echo ">".nim_say("World")."<".PHP_EOL;
# !run php7r dl("nim7.so"); echo ">".nim_add(123, 111)."<".PHP_EOL;

import "../../src/nimzend.nim"

#
# my code
#

proc nim_arrays(zva: ZValArray, zvar: ZValArray) {.phpfunc.} =
  phpPrintf("The %s has %d elements!\n", zva.zvalType, zva.len)

  #echo "Dump Array Values (and transform into some other types)"
  #for zv in zva:
  #  echo $zv, " ", zv.toInt, " ", zv.toFloat

  echo "Dump Array as Key : Value pairs (numeric and string index suppored)"
  for ki, zv in pairs(zva):
    if ki.key == nil:
      echo ki.idx, " : ", $zv
    else:
      echo ki.key, " : ", $zv

    if ki.key != nil and ki.key == "a":
      echo "Psst! Wanna buy an a?"

  echo "At 'b' there is: ", $zva["b"]
  echo "At 'hans' there is: ", $zva["hans"]
  echo "At 'metatexx' there is: ", zva["metatexx"].repr

  echo "At 0 there is: ", $zva[0]
  echo "At 4 there is: ", $zva[4].repr

  # slightly odd but works for ZValArray
  zvar.add 1
  zvar.add 2

finishExtension("narrays","0.1")
