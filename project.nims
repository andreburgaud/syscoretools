import strutils

binDir = "dist"
srcDir = "src"

let buildDir = "build"

# Binaries list
bin = @["wc", "uniq"]

# Package version
let VERSION = "0.1.1"
let NAME = "System Core Tools"

mode = ScriptMode.Verbose
#mode = ScriptMode.Silent

task version, "Show project version and Nim compiler version":
  echo "$#, $#" % [NAME, VERSION]
  exec "nim -v"

task test, "Runs the test suite":
  echo "Running test suite"
  exec "nim c -r tests/all_test"

task release, "Compile syscoretools in release mode":
  rmDir binDir
  mkDir binDir
  withDir "src":
    for exe in bin:
      echo "Building release $#" % exe
      exec "nim -d:release --opt:size c $#.nim" % exe
      echo "Stripping release $#" % exe
      exec "strip $#" % exe.toExe
      echo "Moving executable '$#' to dist directory" % exe
      mvFile (("$#" % exe).toExe, ("../dist/$#" % exe).toExe)

task build, "Compile syscoretools in debug mode":
  mkDir buildDir
  withDir "src":
    for exe in bin:
      echo "Building debug " & exe
      exec "nim c $#.nim" % exe
      echo "Moving executable '$#' to build directory" % exe
      mvFile (("$#" % exe).toExe, ("../build/$#" % exe).toExe)

task clean, "Delete generated binaries":
  for dir in @[binDir, buildDir]:
    echo "Deleting $#" % dir
    rmDir dir
  let allTestExe = "tests/all_test".toExe
  echo "Deleting $#" % allTestExe
  rmFile allTestExe
  for cache in @["src/nimcache", "tests/nimcache"]:
    echo "Deleting cache: $#" % cache
    rmDir cache
