import ospaths
import strutils

when not compiles(extensionName):
  # this hack makes syntax checking of the file working in my IDE
  when getCommand() == "check":
    var extensionName = "check"
  else:
    {.error: "you need to declare the exensionName".}

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

var phpver = gorge(phpConfig & " --vernum")[0..2]
var extensionDir = gorge(phpConfig & " --extension-dir")

if defined(phpinfo) and not compileOption("verbosity", "0"):
  echo "PHP Version " & phpver
  echo "PHP Extension Dir " & extensionDir
  echo "PHP Executable " & phpExe
  echo "PHP Config " & phpConfig

mkDir extensionDir

var extensionFile = extensionDir / extensionName & ".so"

task build, "builds the extension":
  setCommand "c"

  switch("app", "lib")
  switch("d", "nimphpext")
  switch("threads","on")
  switch("d","release")
  switch("d","noSignalHandler")
  switch("gc", "stack") # using the gc:stack of Nim

  # We mangle names (but thats just a hack so far)
  switch("passC","-DNimMain=NimMain" & extensionName)
  switch("passC","-DNimMainInit=NimMain" & extensionName & "Init")
  switch("passC","-DNimMainInner=NimMain" & extensionName & "Inner")

  when defined(macosx):
    switch("l", "-undefined suppress -flat_namespace")
    # -dynamic -fno-common -DPIC -install_name " & extensionDir / extensionName & ".so")
  elif defined(posix):
    switch("l", "-undefined")
  else:
    echo "OS not supported"
    quit 5

  switch("d", "php" & phpver)

  if fileExists(extensionFile):
    when not compileOption("verbosity", "0"):
      echo "Removing previous file '", extensionFile, "'"
    rmFile extensionFile
  when not compileOption("verbosity", "0"):
    echo "Installing to '", extensionFile, "'"
  switch("o", extensionFile)

task clean, "removes the extension from extension dir":
  setCommand "nop"
  if fileExists(extensionFile):
    echo "Removing '", extensionFile, "'"
    rmFile extensionFile
