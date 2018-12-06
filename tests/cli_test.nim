import os, unittest

import lib/cli

suite "cli":

  test "app name":
    check appName() == "all_test"

  test "expand short option":
    check expandOption("h", false) == "-h"
    check expandOption("v") == "-v"

  test "expand long option":
    check expandOption("version", true) == "--version"

  test "validate int input":
    check valRequiredInt("2", "f") == 2

  test "validate int input (exception)":
    expect(ValueError):
      discard valRequiredInt("trois", "f")

  test "validate missing input (exception)":
    expect(ValueError):
      discard valRequiredInt(nil, "f")
