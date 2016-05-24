# this is a specialized config to force php 7.0 compilation
# even if the globally installed version of php differs

var extensionName = "nim7"

when defined(macosx):
  # this is only working for homebrew php installs "but..."
  import ospaths
  import strutils
  var php70Path = gorge("brew --prefix homebrew/php/php70")
  if php70Path.contains("Error"):
    echo "Could not determine PHP 7.0 location"
    quit 5

  var phpConfig = php70Path / "bin" / "php-config"
  var phpExe = php70Path / "bin" / "php"

include "../../src/cfgtpl.nims"

# so that the example finds nimzend.nim even if not installed
switch("p", "../../src/")
switch("d", "release")

task tests, "runs a simple test":
  setCommand "nop"
  exec phpExe & " tests.php"

# following does not work (yet)
task all, "builds and runs":
  build_task()
  tests_task()
