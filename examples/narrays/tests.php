<?php
dl("narrays.so");

$arr=array("a"=>"1","b"=>815,"hans"=>3,4,5,"a");
#unset($arr[0]);
#next($arr);
$ref=array();
print_r(nim_arrays($arr,$ref));
print_r($ref);

