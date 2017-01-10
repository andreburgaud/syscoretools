import unicode, unittest

import lib/core


let str1 = "un deux trois"
let str2 = "Οὐχὶ ταὐτὰ παρίσταταί μοι γιγνώσκειν, ὦ ἄνδρες ᾿Αθηναῖο"
let str3 = "ᚳᛖᚾ᛫ᛒᛦᚦ᛫ᚳᚹᛁᚳᛖᚱᚪ᛫ᚷᛖᚻᚹᚪᛗ᛫ᚳᚢᚦ᛫ᚩᚾ᛫ᚠᛦᚱᛖ"


suite "core":

  test "count words":
    check str1.countWords == 3

  test "count rune words":
    check str2.countRuneWords == 8
    check str3.countRuneWords == 1

  test "count bytes":
    check str1.len == 13

  test "count multibytes":
    check str3.runeLen == 34

