{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module Hah.Configs where

import Prelude
-- import FFI
import MyPrelude
import Hah.Types
-- import JS
-- import ChromeExt

defaultSettings :: [(Method, Key)]
defaultSettings = [
  (StartHitahint,          Key 69  True False),
  (FocusForm,              Key 70  True False),
  (ToggleSelector,         Key 186 True False),
  (Cancel,                 Key 27  False False),
  (MoveNextSelectorCursor, Key 40  False False),
  (MovePrevSelectorCursor, Key 38  False False),
  (MoveNextForm,           Key 34  False False),
  (MovePrevForm,           Key 33  False False),
  (BackHistory,            Key 72  True False)
  ]

keyMap :: [(Int, String)]
keyMap = [
  (9   , "TAB"),
  (16  , "SHIFT"),
  (17  , "CTRL"),
  (18  , "ALT"),
  (27  , "ESC"),
  (33  , "PAGEUP"),
  (34  , "PAGEDONW"),
  (35  , "END"),
  (36  , "HOME"),
  (37  , "BACK"),
  (38  , "UP"),
  (39  , "FORWARD"),
  (40  , "DOWN"),
  (48  , "0"),
  (49  , "1"),
  (50  , "2"),
  (51  , "3"),
  (52  , "4"),
  (53  , "5"),
  (54  , "6"),
  (55  , "7"),
  (56  , "8"),
  (57  , "9"),
  (65  , "A"),
  (66  , "B"),
  (67  , "C"),
  (68  , "D"),
  (69  , "E"),
  (70  , "F"),
  (71  , "G"),
  (72  , "H"),
  (73  , "I"),
  (74  , "J"),
  (75  , "K"),
  (76  , "L"),
  (77  , "M"),
  (78  , "N"),
  (79  , "O"),
  (80  , "P"),
  (81  , "Q"),
  (82  , "R"),
  (83  , "S"),
  (84  , "T"),
  (85  , "U"),
  (86  , "V"),
  (87  , "W"),
  (88  , "X"),
  (89  , "Y"),
  (90  , "Z"),
  (112 , "F1"),
  (113 , "F2"),
  (114 , "F3"),
  (115 , "F4"),
  (116 , "F5"),
  (117 , "F6"),
  (118 , "F7"),
  (119 , "F8"),
  (120 , "F9"),
  (121 , "F10"),
  (122 , "F11"),
  (123 , "F12"),
  (186 , ": (or ;)"),
  (187 , "^"),
  (188 , ","),
  (189 , "-"),
  (190 , ".")
  ]

ctrlKeycode :: Int
ctrlKeycode = 17
altKeycode :: Int
altKeycode = 18

-- data itemType = Tab | History | Bookmark | Websearch | Command
selectorNum :: Int
selectorNum = 20

webSearchList :: [Item]
webSearchList = [
  Item "" "google検索" "https://www.google.co.jp/#hl=ja&q=" "websearch",
  Item "" "alc辞書" "http://eow.alc.co.jp/search?ref=sa&q=" "websearch"
  ]

formInputFields :: String
formInputFields = "input[type=\"text\"]:not(\"#selectorInput\"), textarea, select"
clickables :: String
clickables = "a"
-- CLICKABLES = "a[href],input:not([type=hidden]),textarea,select,*[onclick],button"

_hintKeys :: [(Int, String)]
_hintKeys = [(65, "A"), (66, "B"), (67, "C"), (68, "D"), (69, "E"), (70, "F"), (71, "G"), (72, "H"), (73, "I"), (74, "J"), (75, "K"), (76, "L"), (77, "M"), (78, "N"), (79, "O"), (80, "P"), (81, "Q"), (82, "R"), (83, "S"), (84, "T"), (85, "U"), (86, "V"), (87, "W"), (88, "X"), (89, "Y"), (90, "Z")]
hintKeys :: [(Int, String)]
hintKeys =  [(i1*100+i2, s1 ++ s2)|(i1, s1) <- _hintKeys, (i2, s2) <- _hintKeys]
