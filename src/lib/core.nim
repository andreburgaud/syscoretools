# core generic library
# Exposes core procs common to several tools

import os, sequtils, strutils, system, unicode

# ffi methods
proc c_memchr(s: pointer, c: cint, n: csize): pointer {.
  importc: "memchr", header: "<string.h>".}
proc c_memset(p: pointer, value: cint, size: csize): pointer {.
  importc: "memset", header: "<string.h>", discardable.}
proc c_fgets(c: cstring, n: cint, f: File): cstring {.
  importc: "fgets", header: "<stdio.h>", tags: [ReadIOEffect].}
proc c_clearerr*(f: File): void {.
  importc: "clearerr", header: "<stdio.h>".}

const
  seqShallowFlag = low(int)

type
  TGenSeq {.compilerproc, pure, inheritable.} = object
    len, reserved: int
    when defined(gogc):
      elemSize: int
  PGenSeq {.exportc.} = ptr TGenSeq

template space(s: PGenSeq): int {.dirty.} =
  s.reserved and not seqShallowFlag

proc readRawLine(f: File, line: var TaintedString): bool =
  ## Similar to system.readLine, but also return indication about a line ending
  ## or not with an EOL. The posix tools like 'wc' don't count a line that does
  ## end with ``LF`` or ``CRLF``.
  ## Unlike system.readLine, the EOL characters are not removed from the line.
  var pos = 0
  var sp: cint = 80
  # Use the currently reserved space for a first try
  if line.string.isNil:
    line = TaintedString(newStringOfCap(80))
  else:
    sp = cint(cast[PGenSeq](line.string).space)
    line.string.setLen(sp)
  while true:
    # memset to \l so that we can tell how far fgets wrote, even on EOF, where
    # fgets doesn't append an \l
    c_memset(addr line.string[pos], '\l'.ord, sp)
    if c_fgets(addr line.string[pos], sp, f) == nil:
      line.string.setLen(0)
      return false
    let m = c_memchr(addr line.string[pos], '\l'.ord, sp)
    if m != nil:
      # \l found: Could be our own or the one by fgets, in any case, we're done
      var last = cast[ByteAddress](m) - cast[ByteAddress](addr line.string[0])
      if last > 0 and line.string[last-1] == '\c':
        line.string.setLen(last+1) # Preserve all characters
        return true
        # We have to distinguish between two possible cases:
        # \0\l\0 => line ending in a null character.
        # \0\l\l => last line without newline, null was put there by fgets.
      elif last > 0 and line.string[last-1] == '\0':
        if last < pos + sp - 1 and line.string[last+1] != '\0':
          # Line without new line \0\l\l
          line.string.setLen(last-1) # Remove \0 put by fgets
        else:
          # Ends with \0\l\0. Returned string will end with \0\l
          # Preserves end of line to count all characters including \0\l
          # Like default
          line.string.setLen(last+1)
      else:
        line.string.setLen(last+1) # regular case with \l as eol
      return true
    else:
      # fgets will have inserted a null byte at the end of the string.
      dec sp
    # No \l found: Increase buffer and read more
    inc pos, sp
    sp = 128 # read in 128 bytes at a time
    line.string.setLen(pos+sp)

iterator rawLines*(f: File): (TaintedString){.tags: [ReadIOEffect].} =
  ## Similar to system.lines.
  ## Unlike system.readLine, it returns the line including the EOL characters
  ## character: ``LF`` (\l) or ``CRLF`` (\c\l).
  var res = TaintedString(newStringOfCap(80))
  while f.readRawLine(res): yield (res)

proc readLn(f: File, line: var TaintedString, eol: var bool): bool =
  ## Similar to system.readLine, but also return indication about a line ending
  ## or not with an EOL. The posix tools like 'wc' don't count a line that does
  ## end with ``LF`` or ``CRLF``.
  ## Unlike system.readLine, the EOL characters are not removed from the line.
  var pos = 0
  var sp: cint = 80
  # Use the currently reserved space for a first try
  if line.string.isNil:
    line = TaintedString(newStringOfCap(80))
  else:
    sp = cint(cast[PGenSeq](line.string).space)
    line.string.setLen(sp)
  while true:
    # memset to \l so that we can tell how far fgets wrote, even on EOF, where
    # fgets doesn't append an \l
    c_memset(addr line.string[pos], '\l'.ord, sp)
    if c_fgets(addr line.string[pos], sp, f) == nil:
      line.string.setLen(0)
      return false
    let m = c_memchr(addr line.string[pos], '\l'.ord, sp)
    if m != nil:
      eol = true
      # \l found: Could be our own or the one by fgets, in any case, we're done
      var last = cast[ByteAddress](m) - cast[ByteAddress](addr line.string[0])
      if last > 0 and line.string[last-1] == '\c':
        line.string.setLen(last+1) # Preserve all characters
        return true
        # We have to distinguish between two possible cases:
        # \0\l\0 => line ending in a null character.
        # \0\l\l => last line without newline, null was put there by fgets.
      elif last > 0 and line.string[last-1] == '\0':
        if last < pos + sp - 1 and line.string[last+1] != '\0':
          dec last
          eol = false # Line without new line
          line.string.setLen(last)
        else:
          line.string.setLen(last+1) # Preserve end of line to count all characters
      else:
        line.string.setLen(last+1)
      return true
    else:
      # fgets will have inserted a null byte at the end of the string.
      dec sp
    # No \l found: Increase buffer and read more
    inc pos, sp
    sp = 128 # read in 128 bytes at a time
    line.string.setLen(pos+sp)

iterator lineIter*(f: File): (TaintedString , bool){.tags: [ReadIOEffect].} =
  ## Similar to system.lines.
  ## Unlike system.readLine, it returns the line including the EOL characters
  ## and a boolean indicating if the line was terminated with an expected EOL
  ## character (``LF`` or ``CRLF``).
  var res = TaintedString(newStringOfCap(80))
  var eol = false
  while f.readLn(res, eol): yield (res, eol)

proc countWords*(s: string): int =
  ## Count words when byte count is set (option -c)
  for w in s.splitWhitespace:
    inc result

proc countRuneWords*(s: string): int =
  ## Count words when multibytes (unicode) is set (option -m)
  var isWord = false
  for r in s.runes:
    if r.isWhiteSpace():
      if isWord:
        isWord = false
    else:
      if not isWord:
        isWord = true
        inc result




