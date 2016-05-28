# this is a specialized config to force php 7.0 compilation
# even if the globally installed version of php differs

var extensionName = "nim7"

when defined(macosx) and defined(php70):
  # this is only working for homebrew php installs "but..."
  import ospaths
  import strutils
  var php70Path = gorge("brew --prefix homebrew/php/php70")
  if php70Path.contains("Error"):
    echo "Could not determine PHP 7.0 location"
    quit 5

  var phpConfig = php70Path / "bin" / "php-config"
  var phpExe = php70Path / "bin" / "php"

when defined(macosx) and defined(php54):
  # this is only working for homebrew php installs "but..."
  import ospaths
  import strutils
  var php54Path = gorge("brew --prefix homebrew/php/php54")
  if php54Path.contains("Error"):
    echo "Could not determine PHP 5.4 location"
    quit 5

  var phpConfig = php54Path / "bin" / "php-config"
  var phpExe = php54Path / "bin" / "php"

when not compiles(phpConfig) and getCommand() != "check":
  {.error: "You need to specivy either -d:php54 or -d:php70".}

include "../../src/cfgtpl.nims"

# so that the example finds nimzend.nim even if not installed
switch("p", "../../src/")
switch("d", "release")

task tests, "runs a simple test":
  setCommand "nop"
  exec phpExe & " --version"
  exec phpExe & " tests.php 2>&1"

# following does not work (yet)
task all, "builds and runs":
  build_task()
  tests_task()
