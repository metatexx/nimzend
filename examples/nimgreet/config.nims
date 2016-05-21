import ospaths

var extensionName = "nimgreets"

include ../../config_tpl.nim

task tests, "runs a simple test":
  setCommand "nop"
  exec """php greeter.php'"""
