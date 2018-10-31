version       = "0.7.1"
author        = "citycide"
description   = "Simple command line tool to make git more intuitive, along with useful GitHub addons."
license       = "MIT"
bin           = @["fugitive"]
skipExt       = @["nim"]
binDir        = "dist"
srcDir        = "src"

requires "nim >= 0.19.0 & < 0.20.0"
requires "tempfile >= 0.1.5"

import ospaths, strformat, strutils

const
  flags_win_64 = "--os:windows --cpu:amd64"
  flags_linux_64 = "--os:linux --cpu:amd64"
  flags_macos_64 = "--os:macos --cpu:amd64"
  platforms = [
    ("windows", "amd64", "x64"),
    ("linux", "amd64", "x64"),
    ("macos", "amd64", "x64")
  ]
  distFiles = @["license", "readme.md", "changelog.md"]
  build =
    "nim --cpu:$1 --os:$2 -d:release -d:fugitiveVersion=v$3 " &
    "-o:$4 --verbosity:0 --hints:off c src/fugitive"

proc getZipName (os, arch: string): string =
  let ext = if os == "windows": ".zip" else: ".tar.gz"
  result = &"fugitive_v{version}_{os}_{arch}{ext}"

task build_current, "Build fugitive for the current OS (release)":
  mkDir binDir

  let outFile = "fugitive." & ExeExt
  let outPath = binDir / outFile

  exec "nim c -o:" & outPath & " --verbosity:0 --hints:off -d:release " &
    "-d:fugitiveVersion=v" & version & "  " & srcDir / bin[0]

  let zipName = getZipName(buildOS, buildCPU).multiReplace(
    ("_amd64", "_x64"),
    ("macosx", "macos")
  )
  let params = join(@[zipName, outFile] & distFiles, " ")
  rmFile zipName
  for distFile in distFiles:
    cpFile(distFile, binDir / distFile)

  withDir binDir:
    if buildOS == "windows":
      exec "7z a -tzip " & params
    else:
      exec "tar -czf " & params

  echo zipName

task build_win_x64, "Build fugitive for Windows (development)":
  exec &"nimble build {flags_win_64}"

task build_linux_x64, "Build fugitive for Linux (development)":
  exec &"nimble build {flags_linux_64}"

task build_macos_x64, "Build fugitive for macOS (development)":
  if buildOS == "macosx":
    exec &"nimble build"
  else:
    echo "macOS compilation is not supported on other platforms"

task build_releases, "Build all release versions of fugitive":
  rmDir binDir
  for name, arch, type in platforms.items:
    # TODO: macOS compilation
    if name == "macos": continue

    echo "building for " & name & " " & type & "..."
    let
      folder = name & "-" & type
      outDir = binDir / folder
      outFile = outDir / "fugitive." & ExeExt

    mkDir outDir
    for distFile in distFiles:
      cpFile(distFile, outDir / distFile)
    exec build % [arch, name, version, outFile]

    let zipName = getZipName(name, type)
    let params = join(@[zipName, folder] & distFiles, " ")

    withDir binDir:
      if name == "windows":
        exec "7z a " & params
      else:
        exec "tar -czf " & params

    echo binDir / zipName
    echo ""
