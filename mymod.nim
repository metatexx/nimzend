# nim c --app:lib --d:phpext -d:release -l:"-undefined suppress -flat_namespace" -o:/usr/local/Cellar/php54/5.4.45_3/lib/php/extensions/no-debug-non-zts-20100525/testmod.so --verbosity:0
# runphp dl("testmod.so"); $a=4711; echo nim(1234).' '.substr(nim(-1),0,40);

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


finishExtension("testmod","0.1")
