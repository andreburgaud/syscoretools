# wc - word, line, character, and byte count
# - http://pubs.opengroup.org/onlinepubs/9699919799/utilities/wc.html POSIX wc
# - https://www.freebsd.org/cgi/man.cgi?query=wc FreeBSD man page for wc

import os, sequtils, strutils, system, tables, unicode, pegs

import lib / [ parseopt3, core, cli ]

const
  VERSION = "0.1.1"

  # Title for the line of total counters when several file
  TOTAL = "total"

  # Default space (width) available for each displayed counters
  WIDTH = 7

const HELP = """
Usage: $# [OPTIONS] [FILES]...

  The wc utility displays the number of lines, words, and bytes contained in
  each input file, or standard input (if no file is specified) to the
  standard output. A line is defined as a string of characters delimited by
  a <newline> character. Characters beyond the final <newline> character
  will not be included in the line count.

  A word is defined as a string of characters delimited by white space
  characters. If more than one input file is specified, a line of cumulative
  counts for all the files is displayed on a separate line after the output
  for the last file.

Options:
  -c         The number of bytes in each input file is written to the standard
             output. This will cancel out any prior usage of the -m option.
  -l         The number of lines in each input file is written to the standard
             output.
  -m         The number of characters in each input file is written to the
             standard output. If the current locale does not support multibyte
             characters, this is equivalent to the -c option. This will cancel
             out any prior usage of the -c option.
  -w         The number of words in each input file is written to the standard
             output.
  --version  Show the version and exit.
  --help     Show this message and exit.
"""

type
  Count = enum cBytes, cLines, cMulti, cWords ## Enum indexing the total counters
                                              ## in the counts table of the context

type
  Context = tuple   ## Context containing options and accumulators
    optBytes: bool  ## Option '-c': count bytes (chars)
    optLines: bool  ## Option '-l': count lines (newlines)
    optMulti: bool  ## Option '-m': count multibytes
    optWords: bool  ## Option '-w': count words
    counts: TableRef[Count, int64] ## Table carrying accumulators for total counters

proc printCounter(cpt: int64, width: int) =
  ## Print individual counter
  stdout.write spaces(max(0, width - ($cpt).len)) & $cpt


proc printCounters(ctx: Context, cptBytes: int64, cptLines: int64,
  cptMulti: int64, cptWords: int64, filename: string=nil) =
  ## Print the selected counters for a given files

  if ctx.optLines:
    printCounter(cptLines, WIDTH)

  if ctx.optWords:
    printCounter(cptWords, WIDTH)

  if ctx.optBytes:
    printCounter(cptBytes, WIDTH)

  if ctx.optMulti:
    printCounter(cptMulti, WIDTH)

  if filename != nil:
    echo " $#" % filename
  else:
    echo()

proc processFile(ctx: Context, filename: string=nil) =
  ## Process each file. For each file, iterate through each line.
  ## A file named '-' it is treated as standard input. The arguments may
  ## include more than one '-' (standard input). See POSIX:
  ## http://pubs.opengroup.org/onlinepubs/9699919799/utilities/wc.html#tag_20_154_06
  var cptBytes = 0i64
  var cptLines = 0i64
  var cptMulti = 0i64
  var cptWords = 0i64
  var f: File

  try:

    # '-' is treated as stdin
    if filename == "-" or filename == nil:
      f = stdin
    else:
      f = open(filename)

    # Just need to count the bytes
    if f != stdin and
       ctx.optBytes and
       allIt([ctx.optLines, ctx.optMulti, ctx.optWords], not it):
      cptBytes = f.getFileSize()
    else:
      for ln in f.rawLines:
        # ln is a tuple containing the line and a boolean
        # the boolean is false when there is no eol, true otherwise
        if ctx.optBytes:
          cptBytes += ln.len
        if ctx.optLines:
          if ln[ln.len-1] == '\l':
            # The line has an eol (\l). If no EOL, don't increment the counter.
            inc cptLines
        if ctx.optWords:
          if ctx.optMulti:
            #echo cptWords
            #echo ln.splitWhitespace.len
            if validateUtf8(ln) < 0:
              # Valid utf8
              #cptWords += countRuneWords ln.strip(trailing=true)
              cptWords += countRuneWords ln
            else:
              cptWords += countWords ln
          else:
            cptWords += countWords ln
        if ctx.optMulti:
          if validateUtf8(ln) < 0:
              # Valid utf8
            cptMulti += ln.runeLen
          else:
            cptMulti += ln.len

    ctx.counts[cBytes] += cptBytes
    ctx.counts[cLines] += cptLines
    ctx.counts[cMulti] += cptMulti
    ctx.counts[cWords] += cptWords

    printCounters(ctx, cptBytes, cptLines, cptMulti, cptWords, filename)

  except IOError:
    let msg = getCurrentExceptionMsg()
    printError("$#: $#" % [filename, msg])

  finally:
    if f != nil and f != stdin:
      f.close()
    if f == stdin:
      # Reset stdin if list of files includes another one ('-')
      c_clearerr f

proc printTotal(ctx: Context) =
  printCounters(ctx, ctx.counts[cBytes], ctx.counts[cLines], ctx.counts[cMulti],
   ctx.counts[cWords], TOTAL)

proc doCommand(ctx: Context, inFilenames: seq[string] = nil) =
  var filenames: seq[string] = @[]
  if inFilenames != nil and inFilenames.len > 0:
    for pattern in inFilenames:
      var foundFile = false
      for filename in walkPattern(pattern):
        foundFile = true
        filenames.add filename
      if not foundFile:
        filenames.add pattern

  # if no file: read from stdin
  if filenames.len > 0:
    for filename in filenames:
      processFile(ctx, filename)
  else:
    processFile(ctx)

  if filenames.len > 1:
      printTotal(ctx)

proc initContext(optBytes:bool, optLines:bool,
  optMulti:bool, optWords:bool): Context =
    result = (
      optBytes: optBytes,
      optLines: optLines,
      optMulti: optMulti,
      optWords: optWords,
      counts: {cBytes: 0i64, cLines: 0i64, cMulti: 0i64, cWords: 0i64}.newTable
    )

proc main() =

  # Options
  var optBytes = false # -c
  var optLines = false # -l
  var optMulti = false # -m
  var optWords = false # -w

  # Arguments
  var inFilenames: seq[string] = @[]

  var errorOption = false
  #for kind, key, val in getArgs():
  for kind, key, val in getopt():
    case kind
    of cmdArgument:
      inFilenames.add(key)
    of cmdLongOption:
      case key
      of "help": printHelp(HELP); return
      of "version": printVersion(VERSION); return
      else: unexpectedOption(key, true); errorOption = true
    of cmdShortOption:
      case key
      # last of -c -m takes precedence
      of "c": (optMulti, optBytes) = (false, true)
      of "l": optLines = true
      # last of -c -m takes precedence
      of "m": (optMulti, optBytes) = (true, false)
      of "w": optWords = true
      else: unexpectedOption key; errorOption = true
    of cmdEnd: assert(false)

  if errorOption:
    quit(QuitFailure)

  # Default action: -c, -l and -w options
  if allIt([optBytes, optLines, optMulti, optWords], not it):
    (optBytes, optLines, optWords) = (true, true, true)

  var ctx = initContext(optBytes, optLines, optMulti, optWords)

  setControlCHook(ctrlC)

  doCommand(ctx, inFilenames)

when isMainModule:
  main()
