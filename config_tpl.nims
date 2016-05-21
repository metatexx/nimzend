task build, "builds the extension":
  setCommand "c"
  switch("app", "lib")
  switch("d", "phpext")

  var extensionDir = gorge("php-config --extension-dir")
  if defined(macosx):
    switch("l", "-undefined suppress -flat_namespace")
    # -dynamic -fno-common -DPIC -install_name " & extensionDir / extensionName & ".so")
  elif defined(posix):
    switch("l", "-undefined")
  else:
    echo "OS not supported"
    quit 5

  var phpver = gorge("php-config --vernum")[0..2]
  switch("d", "php" & phpver)

  if fileExists(extensionDir / extensionName & ".so"):
    echo "Removing previous version from: ", extensionDir
    exec("rm " & extensionDir / extensionName & ".so")
  echo "Installing to: ", extensionDir
  switch("o", extensionDir / extensionName & ".so")

task clean, "removes the extension from extension dir":
  setCommand "nop"
  var extensionDir = gorge("php-config --extension-dir")
  echo "Removing from: ", extensionDir
  exec("rm " & extensionDir / extensionName & ".so")
