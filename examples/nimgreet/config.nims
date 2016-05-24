# the extension name
var extensionName = "nimgreets"

# include the configuration template
include "../../src/cfgtpl.nims"

# so that the example finds nimzend.nim even if not installed
switch("p", "../../src/")

# our tests
task tests, "runs a simple test":
  setCommand "nop"
  exec phpExe & """ greeter.php"""
