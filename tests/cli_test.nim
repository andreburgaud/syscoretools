import os, unittest

import lib/cli

suite "cli":

  test "app name":
    check appName() == "all_test"
