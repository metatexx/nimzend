# nim build --verbosity:0
# !run nim tests
# run phpr dl("nimext.so"); echo nim_peg("Var1=key1;var2=Key2;   VAR3").PHP_EOL;
# !run phpr dl("nimext.so"); echo nim_zval("12\0"."3").PHP_EOL;
# !run phpr dl("nimext.so"); echo nim_alpha("12H!e#0&ll3_o?").PHP_EOL;
# !run phpr dl("nimext.so"); echo nim_fun(2.5, "Hello World!", " - ").PHP_EOL;

import "../../src/nimzend.nim"
import math, strutils, pegs

#
# my code
#

proc nim_fun(num: float, txt: string, sep: string = ",", tresh: float = 1.0, foo: int = 123, bar: bool = true) {.phpfunc.} =
  if notDiscarded:
    var r = ""
    var cnt = num.int
    # just for funr
    if num.floor() != num:
      r.add "*"

    if tresh > 0.5:
      r.add "+"

    for i in 0 ..< cnt:
      if i > 0: r.add sep
      r.add txt

    if bar:
      r.add $foo

    returnString(r)

proc nim_alpha(str: string): string {.phpfunc.} =
  result = ""
  for ch in str:
        if ch in {'a'..'z', 'A'..'Z'}:
          result.add ch

proc nim_zval(zv: ZVal) {.phpfunc.} =
  echo zv.kind
  echo zv.value.str.text
  echo zv.value.str.len

proc nim_peg(str: string): string {.phpfunc.} =
  proc handleMatches(m: int, n: int, c: openArray[string]): string =
    result = ""

    if m > 0:
      result.add ", "

    result.add case n:
      of 2: c[0].toLower & ": '" & c[1] & "'"
      of 1: c[0].toLower & ": ''"
      else: ""

  result = str.replace(peg"{\ident}('='{\ident})* ';'* \s*", handleMatches)

finishExtension("nimext","0.1")
