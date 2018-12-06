# uniq - report or filter out repeated lines in a file
# - http://pubs.opengroup.org/onlinepubs/9699919799/utilities/uniq.html POSIX wc
# - https://www.freebsd.org/cgi/man.cgi?query=uniq FreeBSD man page for uniq

import os, sequtils, strutils, system, tables, unicode, pegs

import lib / [ parseopt3, core, cli ]

const
  VERSION = "0.0.1"

const HELP = """
Usage: $# [OPTIONS] [FILES]...

The uniq utility reads the specified input_file comparing adjacent lines, and
writes a copy of each unique input line to the output_file. If input_file is a
single dash ('-') or absent, the standard input is read. If output_file is
absent, standard output is used for output. The second and succeeding copies of
identical adjacent input lines are not written. Repeated lines in the input will
not be detected if they are not adjacent, so it may be necessary to sort the
files first.

The following options are available:

  -c         Precede each output line with the count of the number of times the
             line occurred in the input, followed by a single space.
  -d         Only output lines that are repeated in the input.
  -f num     Ignore the first num fields in each input line when doing
             comparisons. A field is a string of non-blank characters separated
             from adjacent fields by blanks. Field numbers are one based, i.e.,
             the first field is field one.
  -s chars   Ignore the first chars characters in each input line when doing
             comparisons. If specified in conjunction with the -f option, the
             first chars characters after the first num fields will be ignored.
             Character numbers are one based, i.e., the first character is
             character one.
  -u         Only output lines that are not repeated in the input.
  -i         Case insensitive comparison of lines.
  --version  Show the version and exit.
  --help     Show this message and exit.
"""

type
  Context = ref object  ## Context containing options and accumulators
    optCount  : bool    ## Option '-c': count number of time dup line occurred
    optDup    : bool    ## Option '-d': output lines repeated in input
    optFields : int     ## Option '-f': ignore first 'n' fields (starts index 1)
    optChars  : int     ## Option '-s': ignore first 'n' chars (starts index 1)
    optUniq   : bool    ## Option '-u': output lines non repeated in input
    optCaseIns: bool    ## Option '-i': case insensitive line comparison
    #counts: TableRef[Count, int64] ## Table carrying accumulators for total counters

proc initContext(): Context =
    Context(
      optCount  : false,
      optDup    : false,
      optFields : 0,
      optChars  : 0,
      optUniq   : false,
      optCaseIns: false
    )

proc main() =

  var ctx = initContext()

  # Arguments
  var inFilenames: seq[string] = @[]

  var errorOption = false

  try:
    for kind, key, val in getArgs():
      echo "DEBUG >>>", key
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
        of "c":
          ctx.optCount = true
          notImplemented(key)
        of "d":
          ctx.optDup = true
          notImplemented(key)
        of "f":
          #echo "DEBUG >>> $#, $#" % [key, val]
          ctx.optFields = valRequiredInt(val, key)
          notImplemented(key)
        of "s":
          ctx.optChars = valRequiredInt(val)
          notImplemented(key)
        of "u":
          ctx.optUniq = true
          notImplemented(key)
        of "i":
          ctx.optCaseIns = true
          notImplemented(key)
        else: unexpectedOption key; errorOption = true
      of cmdEnd: assert(false)
  except:
    printError getCurrentExceptionMsg()
    quit(QuitFailure)

  if errorOption:
    quit(QuitFailure)

  setControlCHook(ctrlC)

  #doCommand(ctx, inFilenames)

when isMainModule:
  main()