# NimZend

*MIT License - Copyright 2016 Hans Raaf - METATEXX GmbH*

Pre alpha WIP Nim Module for creating PHP extensions using native Zend (unsupported).

## Basic usage of NimZend

For development of NimZend modules you should enable `dl()` (loading of dynamic libraries) in you php.ini. This is the only thing which is not yet handled by the config script. Everything else should work just by calling the nim build tasks from the included config template.

After enabling `dl()` it should be as easy as changing into the `nimext` directory of the examples and running `nim build nimext.nim` followed by `nim tests nimext.nim`. If all works right your PHP cli will execute the code from the extension.

## What is supported?

This is not an auto translation but an manually written Nim interface to the Zend API. Which is itself driven by a huge amount of #define macros.

We only plan to support very basic functionality and types for now and KIS. After all this extension is planned to be used for little helpers to speed up our PHP development.

Still we support PHP 5.3 up to PHP 7.0 now. While out first experiments are mainly for PHP 5.4 this will eventually shift to PHP 7.0.

## Creating your own NimZend modules

To create your own modules you can use `nimble install` in the repository root to install nimzend as a local package. After this you can include both "nimzend.nim" and "cfgtpl.nims" in your modules. Simply copy one of the examples as stand alone directory and adjust the paths to the module to not be relative anymore.

P.S.: We do not support Windows building on windows and probably never will. PRs which are not to convoluted may be accepted though.

Have Fun!

*The Team of METATEXX GmbH*
