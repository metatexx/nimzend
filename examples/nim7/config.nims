var extensionName = "nim7"

include "../../src/cfgtpl.nims"

# so that the example finds nimzend.nim even if not installed
switch("p", "../../src/")
switch("d", "release")

task tests, "runs a simple test":
  setCommand "nop"
  exec """php -r 'dl("""" & extensionName & """.so");  echo ">".nim_long()."<".PHP_EOL;'"""
