# System Core Tools

## Description

**SysCoreTools** is an attmpt to implement a small subset of the tools as defined in the *The Open Group Base Specifications Issue 7, Shell and Utilities*, similar to the **GNU Coreutils**, albeit not so elaborated.

## Goals

* Expose the useful functionalities of some of the classic Shell Utilities invaluable on any *NIX platform, to Windows. Although testing is performed on other platforms (i.e. Mac, Linux), in an effort to be mostly platform agnostic, the main target remains Windows.
* Generate small native and possibly fast executables to ease distribution and user experience.
* As a side effect, learn the Nim programming language (http://nim-lang.org/)

## Similar Projects

* Cross-platform Rust rewrite of the GNU coreutils: https://github.com/uutils/coreutils
* GnuWin http://gnuwin32.sourceforge.net/
* GNU utilities for Win32: http://unxutils.sourceforge.net/

## Build All

* Install Nim, available at http://nim-lang.org/
* Clone the **SysCoreTools** repository: `git clone https://github.com/andreburgaud/syscoretools`
* In the `syscoretools` root directory, use `project.nims` (nimscript), as follow:
```
$ nim release project`
```
* The executable(s) will be compiled and copied in the `dist` subdirectory

## Compile and Run Individual Tools

This approach is useful when working on a particular tool, by avoiding to build everything available in the `src` directory.

Example with `wc` (*word count*):

```
> cd src
> nim c wc.nim
```

The executable will be generated in the same directory (`src`)

or in `release` mode:

```
> cd src
> nim -d:release c wc.nim
```

If you have `strip` (from mingw64) available in your path, you can further reduce the size of the executable with the following command, on Windows:

```
> strip wc.exe
```

or on a *NIX variant:

```
$ strip wc
```

To run the executable:

```
> wc --help
```

## Tests

Some basic tests can be executed with:

```
> nim test project
```

## Other Available Build Tasks

To list other build tasks available, execute: `nim help project`

```
$ nim help project
version              Show project version and Nim compiler version
test                 Runs the test suite
release              Compile syscoretools in release mode
build                Compile syscoretools in debug mode
clean                Delete generated binaries
```

## Release Notes

* Version 0.1.1 (01/10/2017):
  * Replaced `nimble` with a basic nimscript
  * Removed dependency on package `strfmt`
  * `wc` version 0.1.1

* Version 0.1.0 (01/9/2017):
  * First release
  * Built with Nim 0.16.0
  * Tool available: `wc` version 0.1.0

## Legal

**System Core Tools** is distributed under the MIT License: see included [License file](LICENSE.md).

To be respectful of the license, I have no knowledge of and don't look at the code of any of the GNU coreutils implementation released under one of the GPL family licenses. But, I may compare the results of the GNU tools execution to validate progress with comparable tools in **SysCoreTools**.

The help displayed for the each tool may include portion of the documentation copied from the corresponding tool in the BSD General Command Manual. The FreeBSD Documentation License is available at the following link: https://www.freebsd.org/copyright/freebsd-doc-license.html.

## Resources

* http://nim-lang.org/
* http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html The Open Group Base Specifications Issue 7, Shell and Utilities
* http://www.gnu.org/software/coreutils/coreutils.html Coreutils - GNU core utilities
