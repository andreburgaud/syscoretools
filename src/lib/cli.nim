# cli generic library
# Exposes cli procs common to several tools

import os, strutils, terminal, parseopt3

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

proc printWarning*(msg: string) =
  styledWriteLine(stderr, fgYellow, "$#: $#" % [appName(), strip(msg)])

proc expandOption*(key: string, isLong: bool=false): string =
  if isLong: "--$#" % key else: "-$#" % key

proc unexpectedOption*(key: string, isLong: bool=false) =
  printError("$#: unexpected option" % expandOption(key, isLong))

proc ctrlC*() {.noconv.} =
  ## Handler invoked by setControlCHook when a Control C is captured.
  styledEcho(fgYellow, "$#: manually interruped." % appName())
  quit QuitSuccess

proc notImplemented*(key: string, isLong:bool=false) =
  printWarning("$#: option not implemented" % expandOption(key, isLong))

proc valRequiredInt*(val: string, key: string=nil, isLong:bool=false): int =
  if val == nil:
    raise newException(ValueError, "$#: int value is required" % expandOption(key, isLong))
  if not isDigit(val):
    raise newException(ValueError, "$#: [$#]: invalid input" % [expandOption(key, isLong), val])
  parseInt(val)

iterator getArgs*(cmdline=commandLineParams(), shortBools: string = nil,
                  longBools: seq[string] = nil, requireSeparator=false,
                  sepChars="=:", stopWords: seq[string] = @[]): GetoptResult =
  ## Same as parseopt3.getopts, with requireSeparator set to false to comply
  ## with POSIX specs (e.g. option with value int as follow: --option 3)
  var p = initOptParser(cmdline, shortBools, longBools, requireSeparator,
                        sepChars, stopWords)
  while true:
    next(p)
    if p.kind == cmdEnd: break
    yield (p.kind, p.key, p.val)