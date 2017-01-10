# cli generic library
# Exposes cli procs common to several tools

import os, strutils, terminal

proc appName*(): string =
  ## Retrieve application (executable) name, without path and without extension.
  splitFile(getAppFilename())[1]

# Errors and Messages
proc printHelp*(help: string) =
  if help != nil:
    styledEcho(fgGreen, help % appName())
  quit QuitSuccess

proc printVersion*(version: string) =
  styledEcho(fgGreen, "$# version $#" % [appName(), version])
  quit QuitSuccess

proc printError*(msg: string) =
  styledWriteLine(stderr, fgRed, "$#: $#" % [appName(), strip(msg)])

proc unexpectedOption*(key: string, long:bool=false) =
  var k: string
  if long:
    k = "--$#" % key
  else:
    k = "-$#" % key
  printError("$#: Unexpected option" % k)

proc ctrlC*() {.noconv.} =
  ## Handler invoked by setControlCHook when a Control C is captured.
  styledEcho(fgYellow, "$#: manually interruped." % appName())
  quit QuitSuccess
