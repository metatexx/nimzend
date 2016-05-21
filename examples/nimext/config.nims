var extensionName = "nimext"

include "../../src/cfgtpl.nims"

# so that the example finds nimzend.nim even if not installed
switch("p", "../../src/")
switch("d", "release")

task tests, "runs a simple test":
  setCommand "nop"
  exec """php -r 'dl("""" & extensionName & """.so");  echo nim_fun(2.5, "Hello World!", " - ").PHP_EOL;'"""
  exec """php -r 'dl("""" & extensionName & """.so");  echo nim_alpha("1!2N%im3L&4a/ng5").PHP_EOL;'"""
