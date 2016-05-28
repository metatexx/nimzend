# NimZend

*MIT License - Copyright 2016 Hans Raaf - METATEXX GmbH*

Pre alpha WIP Nim Module for creating PHP extensions using native Zend (unsupported).

## Basic usage of NimZend

For development of NimZend modules you should enable `dl()` (loading of dynamic libraries) in you php.ini. This is the only thing which is not yet handled by the config script. Everything else should work just by calling the nim build tasks from the included config template.

After enabling `dl()` it should be as easy as changing into the `nimext` directory of the examples and running `nim build nimext.nim` followed by `nim tests nimext.nim`. If all works right your PHP cli will execute the code from the extension.

Code for you module can be as simple as:

File: `nimfun.nim`

```nim
import nimzend

proc nimFun(a: int, b: int): ZValArray {.phpfunc.} =
  result["add"] = a + b
  result["sub"] = a - b
  result["concat"] = $a & $b
  var arr = zvalArray()
  arr.add a
  arr.add b
  result["array"] = arr

finishExtension("nimfun.so", "0.1")
```

File: `config.nims`

```nim
# the extension name
var extensionName = "nimfun"

# include the configuration template
include "cfgtpl.nims"

# our tests
task tests, "runs a simple test":
  setCommand "nop"
  exec phpExe & """ test.php"""
```

File: `test.php`

```php
<?php
dl("nimfun.so");
print_r(nimFun(124, 111));
```

Building, installing and testing the extension is pretty easy

Shell:

```
> nim build nimfun
building ...
installing ...

> nim tests
Array
(
    [add] => 235
    [sub] => 13
    [concat] => 124111
    [array] => Array
        (
            [0] => 124
            [1] => 111
        )

)
```

*P.S.: The above code is [here](examples/nimfun)*

## What is supported?

This is not an auto translation but an manually written Nim interface to the Zend API. Which is itself driven by a huge amount of #define macros.

We only plan to support basic functionality and types for now.

The code support building of PHP 5.3 up to PHP 7.0 extensions with the same Nim source. While out first experiments are mainly for PHP 5.4 this will eventually shift to PHP 7.0. Maybe some day in the future we will remove the support for PHP < 7. After all PHP 5 will be deprecated in August 2016.

## Creating your own NimZend modules

To create your own modules you can use `nimble install` in the repository root to install nimzend as a local package. After this you can include both "nimzend.nim" and "cfgtpl.nims" in your modules. Simply copy one of the examples as stand alone directory and adjust the paths to the module to not be relative anymore.

P.S.: We do not support Windows and probably never will. PRs which are not to convoluted may be accepted though.

Have Fun!

*The Team of METATEXX GmbH*
