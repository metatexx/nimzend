# nim build -d:php70 --verbosity:0 --hints:off
# run nim tests -d:php70
# !run php7r dl("nim7.so"); echo ">".nim_say("World")."<".PHP_EOL;
# !run php7r dl("nim7.so"); echo ">".nim_add(123, 111)."<".PHP_EOL;

import "../../src/nimzend.nim"

#
# my code
#

when defined(release):
  {.error: "WTF?".}

proc nim_arrays(zva: ZValArray): ZValArray {.phpfunc.} =
  phpPrintf("The %s has %d elements!\n", zva.zvalType, zva.len)

  var pos: ZendPosition # 7.0 "uint32" / 5.x ptr ZendBucketObj

  echo "Array"
  echo "("
  zend_hash_internal_pointer_reset_ex(zva.zendArray, pos.addr)
  while(true):
    when defined(php700):
      var elm: ZVal
      elm = zend_hash_get_current_data_ex(zva.zendArray, pos.addr);
      if elm == nil:
        break;

      var key: ZendString
      var idx: uint64

      zend_hash_get_current_key_ex(zva.zendArray, key.addr, idx.addr, pos.addr)

      if key != nil:
        echo "    [", key.val, "] => ", elm.value.lval
      else:
        echo "    [", idx, "] => ", elm.value.lval

    else:
      var elm: ptr ZVal
      zend_hash_get_current_data_ex(zva.zendArray, elm.addr, pos.addr)
      if elm == nil:
        break;

      var key: cstring
      var len: uint32
      var idx: uint64

      zend_hash_get_current_key_ex(zva.zendArray, key.addr, len.addr, idx.addr, false, pos.addr)
      if len != 0:
        echo "    [", key, "] => ", elm.value.long
      else:
        echo "    [", idx, "] => ", elm.value.long

    zend_hash_move_forward_ex(zva.zendArray, pos.addr)

  echo ")"

  #phpPrintf("It's a %s\n", zv1.zvalType)

  result.add "Test"

  var arr = zvalArray()
  arr[4711] = "0815"

  result.add arr

  result["foo"] = "bar"

  #result = arr # will throw runtime error

finishExtension("narrays","0.1")
