# Package

version       = "0.0.1"
author        = "Will Reed"
description   = "Easy linux daemon (re)launcher"
license       = "BSD-3-Clause"
srcDir        = "."
installExt    = @["nim"]


namedBin["main"] = "dayemon"


# Dependencies

requires "nim >= 1.6.14"
requires "yaml"
