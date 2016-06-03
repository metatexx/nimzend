# name of the extension
const extensionName = "narrays"

# so that the example finds nimzend.nim even if not installed
include "../../src/cfgtpl.nims"
switch("p", "../../src/")

task tests, "runs a simple test":
  setCommand "nop"
  #exec phpExe & " --version"
  exec phpExe & " tests.php 2>&1"
