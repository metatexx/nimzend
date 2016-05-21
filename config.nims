import ospaths

var extensionName = "nimext"

include config_tpl

task tests, "runs a simple test":
  setCommand "nop"
  exec """php -r 'dl("""" & extensionName & """.so");  echo nimfun(2.5, "Hello World!", " - ").PHP_EOL;'"""
