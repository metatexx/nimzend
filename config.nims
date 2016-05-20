import ospaths

var extensionName = "nimext"

task build, "builds the extension":
  setCommand "c"
  switch("app", "lib")
  switch("d", "phpext")
  switch("l", "-undefined suppress -flat_namespace")
  var extensionDir = gorge("php-config --extension-dir")
  if fileExists(extensionDir / extensionName & ".so"):
    echo "Removing previous version from: ", extensionDir
    exec("rm " & extensionDir / extensionName & ".so")
  echo "Installing to: ", extensionDir
  switch("o", extensionDir / extensionName & ".so")

task test, "runs a simple test":
  setCommand "nop"
  exec """php -r 'dl("""" & extensionName & """.so"); echo nim(123).PHP_EOL; echo nim(-1).PHP_EOL;'"""

task clean, "removes the extension from extension dir":
  setCommand "nop"
  var extensionDir = gorge("php-config --extension-dir")
  echo "Removing from: ", extensionDir
  exec("rm " & extensionDir / extensionName & ".so")
