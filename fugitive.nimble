version       = "0.1.0"
author        = "citycide"
description   = "Simple command line tool to make git more intuitive, along with useful GitHub addons."
license       = "MIT"
bin           = @["fugitive"]
skipExt       = @["nim"]
binDir        = "dist"
srcDir        = "src"

requires "nim >= 0.17.1"
requires "colorize >= 0.2.0"
