version       = "0.5.0"
author        = "citycide"
description   = "Simple command line tool to make git more intuitive, along with useful GitHub addons."
license       = "MIT"
bin           = @["fugitive"]
skipExt       = @["nim"]
binDir        = "dist"
srcDir        = "src"

# some breaking changes in `0.18.1` affect fugitive (`times`, `sugar`)
requires "nim >= 0.18.0 & < 0.18.1"
requires "tempfile >= 0.1.5"

import ospaths
import strutils

const
  flags_win_64 = "--os:windows --cpu:amd64"
  flags_linux_64 = "--os:linux --cpu:amd64"
  flags_macos_64 = "--os:macos --cpu:amd64"
  platforms = [
    ("windows", "amd64", "x64"),
    ("linux", "amd64", "x64"),
    ("macos", "amd64", "x64")
  ]
  build =
    "nim --cpu:$1 --os:$2 -d:release -d:fugitiveVersion=v$3 " &
    "-o:$4 --verbosity:0 --hints:off c src/fugitive"

proc getZipName (os, arch: string): string =
  let ext = if os == "windows": ".zip" else: ".tar.gz"
  result = "fugitive_v" & version & "_" & os & "_" & arch & ext

task build_current, "Build fugitive for the current OS":
  let
    exeExt = when defined(windows): ".exe" else: ""
    outFile = binDir / "fugitive" & exeExt

  exec "nim -d:release -d:fugitiveVersion=v" & version &
    " -o:" & outFile & " --verbosity:0 --hints:off c src/fugitive"

task build_win_x64, "Build fugitive for Windows (x64)":
  exec "nimble build " & flags_win_64

task build_linux_x64, "Build fugitive for Linux (x64)":
  exec "nimble build " & flags_linux_64

task build_macos_x64, "Build fugitive for macOS (x64)":
  # exec "nimble build " & flags_macos_64
  echo "macOS compilation is not supported on other platforms yet"

task make, "Build all release versions of fugitive":
  rmDir binDir
  for name, arch, type in platforms.items:
    # TODO: macOS compilation
    if name == "macos": continue

    echo "building for " & name & " " & type & "..."
    let
      folder = name & "-" & type
      outDir = binDir / folder
      exeExt = if name == "windows": ".exe" else: ""
      outFile = outDir / "fugitive" & exeExt

    mkDir outDir
    exec build % [arch, name, version, outFile]

    let zipName = getZipName(name, type)
    let params = zipName & " " & folder

    withDir "dist":
      if name == "windows":
        exec "zip -9rq " & params
      else:
        exec "tar cfz " & params

    echo "dist" / zipName
    echo ""
