import ospaths
import strutils

when defined(macosx):
  # this is only working for homebrew php installs "but..."
  when defined(php70):
    var phpVer="70"
  elif defined(php54):
    var phpVer="54"
  elif defined(php55):
    var phpVer="55"
  elif defined(php56):
    var phpVer="56"

  when compiles(phpVer):
    var phpPath = gorge("brew --prefix homebrew/php/php" & phpVer)
    if phpPath.contains("Error"):
      echo "Could not determine PHP ", phpVer ," location: "
      echo phpPath
      quit 5

    var phpConfig = phpPath / "bin" / "php-config"
    var phpExe = phpPath / "bin" / "php"

when not compiles(phpConfig):
  var phpConfig* = gorge("which php-config");
  if not phpConfig.endsWith "/php-config":
    echo "No 'php-config' found!"
    quit 5

when not compiles(phpExe):
  var phpExe* = gorge("which php");
  if not phpExe.endsWith "/php":
    echo "No 'php' executable found!"
    quit 5

var phpRev = gorge(phpConfig & " --vernum")[0..2]
var extensionDir = gorge(phpConfig & " --extension-dir")

if defined(phpinfo) and not compileOption("verbosity", "0"):
  echo "PHP Revision " & phpRev
  echo "PHP Extension Dir " & extensionDir
  echo "PHP Executable " & phpExe
  echo "PHP Config " & phpConfig

proc getExtensionFile(): string =
  when not compiles(extensionName):
    # this hack makes syntax checking of the file working in my IDE
    when getCommand() == "check":
      var extensionName = "check"
    else:
      {.error: "you need to declare the exensionName".}

  mkDir extensionDir

  result = extensionDir / extensionName & ".so"

task build, "builds the extension":
  setCommand "c"

  switch("app", "lib")
  switch("d", "nimphpext")
  #switch("threads","on")
  #switch("d","release") # should be only set by user!
  switch("d","noSignalHandler")
  switch("gc", "stack") # using the gc:stack of Nim

  when defined(macosx):
    switch("l", "-undefined dynamic_lookup")
    #switch("l", "-undefined suppress -flat_namespace")
  elif defined(posix):
    switch("l", "-undefined")
  else:
    echo "OS not supported"
    quit 5

  switch("d", "php" & phpRev)

  let extensionFile = getExtensionFile()
  if fileExists(extensionFile):
    when not compileOption("verbosity", "0"):
      echo "Removing previous file '", extensionFile, "'"
    rmFile extensionFile
  when not compileOption("verbosity", "0"):
    echo "Installing to '", extensionFile, "'"
  switch("o", extensionFile)

task clean, "removes the extension from extension dir":
  setCommand "nop"

  let extensionFile = getExtensionFile()
  if fileExists(extensionFile):
    echo "Removing '", extensionFile, "'"
    rmFile extensionFile
