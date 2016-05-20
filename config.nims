import ospaths

var extensionName = "nimext"

task build, "builds the extension":
  setCommand "c"
  switch("app", "lib")
  switch("d", "phpext")
  switch("l", "-undefined suppress -flat_namespace")
  var extensionDir = gorge("php-config --extension-dir")
  echo "Installing to: ", extensionDir
  switch("o", extensionDir / extensionName & ".so")

task test, "runs a simple test":
  exec """php -r 'dl("""" & extensionName & """.so"); echo nim(123).PHP_EOL; echo nim(-1).PHP_EOL;'"""
