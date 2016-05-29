<?php
dl("narrays.so");

$arr=array("a"=>"1","b"=>815,"hans"=>3,4,5);
#unset($arr[0]);
#next($arr);
print_r(nim_arrays($arr));
