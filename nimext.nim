# nim build --verbosity:0
# runphp dl("nimext.so"); $a=4711; echo nim(1234).' '.substr(nim(-1),0,40);

import nimzend

#
# my code
#

proc nim() {.phpfunc.} =
  var l1: int

  if zend_parse_parameters(ht, "l", l1.addr) != 0:
    l1 = 815

  var x = pmalloc(100)
  pfree(x)

  if notDiscarded:
    if l1 > 0:
      return_long(l1)
    else:
      var s: seq[int] = @[]

      for i in 1..5:
        s.add i
      return_string(s.repr)


finishExtension("nimext","0.1")
