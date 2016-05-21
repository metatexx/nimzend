var extensionName = "nimext"

include "../../src/cfgtpl.nims"

# so that the example finds nimzend.nim even if not installed
switch("p", "../../src/")

task tests, "runs a simple test":
  setCommand "nop"
  exec """php -r 'dl("""" & extensionName & """.so");  echo nimfun(2.5, "Hello World!", " - ").PHP_EOL;'"""
