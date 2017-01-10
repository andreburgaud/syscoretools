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

## Build

* Install Nim, available at http://nim-lang.org/
* Clone the **SysCoreTools** repository: `git clone https://github.com/andreburgaud/syscoretools`
* In the `syscoretools` directory: `nimble dist`
* The executable(s) will be generated in the `dist` subdirectory

## Tests

Some basic tests can be executed via: `nimble test`

## Other Tasks

To list other tasks available, execute: `nimble tasks`

```
$ nimble tasks
version              Show Nim compiler version
test                 Runs the test suite
dist                 Compile syscoretools in release mode
build                Compile syscoretools in debug mode
clean                Delete generated binaries
rmcache              Remove Nim cache(s)
```

## Release Notes

* Version 0.1.0 (01/9/2017):
  * First release
  * Built with Nim 0.16.0
  * Tool available: `wc` version 0.1.0

## License

MIT License: see included [License file](LICENSE.md).

To be respectful of the licenses, I have no knowledge of and don't look at the code of any of the GNU coreutils implementation released under one of the GPL family licenses. But, I may compare the results of the GNU tools execution to validate progress with comparable tools in **SysCoreTools**.

## Resources

* http://nim-lang.org/
* http://pubs.opengroup.org/onlinepubs/9699919799/utilities/contents.html The Open Group Base Specifications Issue 7, Shell and Utilities
* http://www.gnu.org/software/coreutils/coreutils.html Coreutils - GNU core utilities
