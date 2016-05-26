task build, "Builds and runs":
  echo "Building nimdl1.nim"
  echo gorge("nim build --verbosity:1 nimdl1.nim 2>&1")
  echo ""
  echo "Building nimdl2.nim"
  echo gorge("nim build --verbosity:1 nimdl2.nim 2>&1")
  try:
    echo ""
    echo "Test 1:"
    echo gorge("php -r '@dl(\"nimdl1.so\"); @dl(\"nimdl2.so\"); echo dl1(1).dl2().PHP_EOL;' 2>&1")
  except: discard

  try:
    echo ""
    echo "Test 2:"
    echo gorge("php -r '@dl(\"nimdl2.so\"); @dl(\"nimdl1.so\"); echo dl1(1).dl2().PHP_EOL;' 2>&1")
  except: discard
