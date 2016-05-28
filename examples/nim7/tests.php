<?php
dl("nim7.so");

echo ">".nim_say("Hello!")."<".PHP_EOL;
echo ">".nim_add(123, 111)."<".PHP_EOL;
print_r(nim_arr(array(1,2,3,4)));


$txt = "";
for($i = 0; $i < 100; $i++) {
  $txt .= nim_say($i).PHP_EOL;
}
$tmp = $txt;
gc_collect_cycles();

if($tmp == $txt) {
  echo "same";
} else {
  echo "???";
}
