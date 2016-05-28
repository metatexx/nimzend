# nim build
# run nim tests

import nimzend

proc nimFun(a: int, b: int): ZValArray {.phpfunc.} =
  result["add"] = a + b
  result["sub"] = a - b
  result["concat"] = $a & $b
  var arr = zvalArray()
  arr.add a
  arr.add b
  result["array"] = arr

finishExtension("nimfun.so", "0.1")
