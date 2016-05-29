var extensionName = "nimext"

include "../../src/cfgtpl.nims"

# so that the example finds nimzend.nim even if not installed
switch("p", "../../src/")

task tests, "runs a simple test":
  setCommand "nop"
  exec phpExe & """ -r 'dl("""" & extensionName & """.so");  echo nim_fun(2.5, "Hello World!", " - ").PHP_EOL;'"""
  exec phpExe & """ -r 'dl("""" & extensionName & """.so");  echo nim_alpha("1!2N%im3L&4a/ng5").PHP_EOL;'"""
  exec phpExe & """ -r 'dl("""" & extensionName & """.so");  echo nim_peg("Var1=key1;var2=Key2;   VAR3").PHP_EOL;'"""
