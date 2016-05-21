import ospaths

when not compiles(extensionName):
  # this hack makes syntax checking of the file working in my IDE
  when paramStr(1) == "check":
    var extensionName = "check"
  else:
    {.error: "you need to declare the exensionName".}

var phpver = gorge("php-config --vernum")[0..2]
var extensionDir = gorge("php-config --extension-dir")
var extensionFile = extensionDir / extensionName & ".so"

task build, "builds the extension":
  setCommand "c"
  switch("app", "lib")
  switch("d", "phpext")

  if defined(macosx):
    switch("l", "-undefined suppress -flat_namespace")
    # -dynamic -fno-common -DPIC -install_name " & extensionDir / extensionName & ".so")
  elif defined(posix):
    switch("l", "-undefined")
  else:
    echo "OS not supported"
    quit 5

  switch("d", "php" & phpver)

  if fileExists(extensionFile):
    echo "Removing previous version '", extensionFile, "'"
    rmFile extensionFile
  echo "Installing '", extensionFile, "'"
  switch("o", extensionFile)

task clean, "removes the extension from extension dir":
  setCommand "nop"
  if fileExists(extensionFile):
    echo "Removing '", extensionFile, "'"
    rmFile extensionFile
