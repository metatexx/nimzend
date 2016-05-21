import ospaths

var extensionName = "nimext"

task build, "builds the extension":
  setCommand "c"
  switch("app", "lib")
  switch("d", "phpext")

  if defined(macosx):
    switch("l", "-undefined suppress -flat_namespace")
  elif defined(posix):
    switch("l", "-undefined")
  else:
    echo "OS not supported"
    quit 5

  var phpver = gorge("php-config --vernum")[0..2]
  switch("d", "php" & phpver)

  var extensionDir = gorge("php-config --extension-dir")
  if fileExists(extensionDir / extensionName & ".so"):
    echo "Removing previous version from: ", extensionDir
    exec("rm " & extensionDir / extensionName & ".so")
  echo "Installing to: ", extensionDir
  switch("o", extensionDir / extensionName & ".so")

task tests, "runs a simple test":
  setCommand "nop"
  exec """php -r 'dl("""" & extensionName & """.so");  echo nimfun(2.5, "Hello World!", " - ").PHP_EOL;'"""

task clean, "removes the extension from extension dir":
  setCommand "nop"
  var extensionDir = gorge("php-config --extension-dir")
  echo "Removing from: ", extensionDir
  exec("rm " & extensionDir / extensionName & ".so")
