version       = "0.11.2"
author        = "haltcase"
description   = "Simple command line tool to make git more intuitive, along with useful GitHub addons."
license       = "MIT"
bin           = @["fugitive"]
skipExt       = @["nim"]
binDir        = "dist"
srcDir        = "src"

requires "nim >= 1.0.0 & < 2.0.0"
requires "gara >= 0.2.0"
requires "tempfile >= 0.1.7"
requires "unpack >= 0.5.0"

import ospaths, strformat, strutils

template exe (basename: string): string =
  if ExeExt == "": basename else: basename & "." & ExeExt

const
  distFiles = @["license", "readme.md", "changelog.md"]
  staticArgs = "--verbosity:0 --hints:off -d:release"
  outFile = "fugitive".exe
  build = "nim c -o:$1 $2 -d:fugitiveVersion=v$3 $4"

proc getZipName (os, arch: string): string =
  let ext = if os == "windows": ".zip" else: ".tar.gz"
  result = &"fugitive_v{version}_{os}_{arch}{ext}"

task release, "Build fugitive for the current OS (release)":
  mkDir binDir

  exec build % [
    binDir / outFile,
    staticArgs,
    version,
    srcDir / bin[0]
  ]

after release:
  let
    zipName = getZipName(buildOS, buildCPU).multiReplace(
      ("_amd64", "_x64"),
      ("macosx", "macos")
    )
    params = join(@[zipName, outFile] & distFiles, " ")

  rmFile zipName

  for distFile in distFiles:
    cpFile(distFile, binDir / distFile)

  withDir binDir:
    if buildOS == "windows":
      exec "7z a -tzip " & params
    else:
      exec "tar -czf " & params

task prep_release, "Prepare for release":
  let
    fugitive = "fugitive".findExe
    git = "git".findExe

  if fugitive == "":
    echo "Could not locate `fugitive` for updating the changelog."
    echo "Please run `nimble install fugitive` or ensure it is in your PATH."
  elif git == "":
    echo "Could not locate `git`. Please install it or ensure it is in your PATH."
  else:
    exec &"{fugitive} changelog changelog.md -t:v" & version
    exec &"{git} add changelog.md fugitive.nimble"
    exec &"{git} commit -m \"release: " & version & "\""
    exec &"{git} tag -a v" & version & " -m v" & version
