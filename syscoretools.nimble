import strutils

# Package

version       = "0.1.0"
author        = "andre burgaud"
description   = "System Core Tools (System Core Tools)"
license       = "MIT"

# Dependencies

requires "nim >= 0.16.0", "strfmt"

# Files - Directories

skipDirs = @["lib"]
skipFiles = @["wc.nim"]

binDir = "dist"
srcDir = "src"

bin = @["wc"]

# Tasks

task version, "Show Nim compiler version":
  exec "nim -v"

task test, "Runs the test suite":
  exec "nim c -r tests/all_test"

before dist:
  if dirExists binDir:
    rmDir binDir
  mkDir binDir

task dist, "Compile syscoretools in release mode":
  withDir "src":
    for app in bin:
      echo "Building release " & app
      exec "nim -d:release --opt:size c $#.nim && strip $#" % [app, app.toExe]
      mvFile (("$#" % app).toExe, ("../dist/$#" % app).toExe)

before build:
  if not dirExists "build":
    mkDir "build"

task build, "Compile syscoretools in debug mode":
  withDir "src":
    for app in bin:
      echo "Building debug " & app
      exec "nim c $#.nim" % app
      mvFile (("$#" % app).toExe, ("../build/$#" % app).toExe)

task clean, "Delete generated binaries":
  if dirExists binDir:
    rmDir binDir

  if dirExists "build":
    rmDir "build"

  if fileExists "tests/all_test".toExe:
    rmFile "tests/all_test".toExe

  exec "nimble rmcache"

task rmcache, "Remove Nim cache(s)":
  for cache in @["src/nimcache", "tests/nimcache"]:
    if dirExists cache:
      rmDir cache

