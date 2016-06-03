# this is a specialized config to force php 7.0 compilation
# even if the globally installed version of php differs

var extensionName = "helloarray"

include "../../src/cfgtpl.nims"

# so that the example finds nimzend.nim even if not installed
switch("p", "../../src/")

task tests, "runs a simple test":
  setCommand "nop"
  #exec phpExe & " --version"
  exec phpExe & " tests.php 2>&1"

# following does not work (yet)
task all, "builds and runs":
  build_task()
  tests_task()
