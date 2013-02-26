{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module ChromeExtFay where

import Prelude
import FFI

import MyPrelude

main :: Fay ()
main = do
  ready $ do
--     chromeStorageSyncSet "{\"aahoge\":\"XX12345\"}"
--     chromeStorageSyncGet "aahoge" (\d -> do{putStrLn "aahoge";putStrLn (showString d)})
    putStrLn $ show $ keyMapper (Key 80 True False) defaultSettings
    putStrLn $ show $ keyMapper (Key 186 True False) defaultSettings
    body <- select "body"
    append "<div id=\"selectorConsole\"><form id=\"selectorForm\"><input id=\"selectorInput\" type=\"text\" /></form></div>" body
    makeSelectorConsole ([(Item "id00" "title00" "url00" "type00"),(Item "id01" "title01" "url01" "type01")])
    putStrLn $ snd $ hintKeys!!0
    putStrLn $ snd $ hintKeys!!110
    putStrLn $ show $ fst $ hintKeys!!1
    putStrLn $ show $ fromJust $ keyCodeToIndex 69 71
    putStrLn $ show $ fromJust $ indexToKeyCode 110
    putStrLn $ show $ isHitAHintKey 70
    putStrLn $ show $ isHitAHintKey 7
    putStrLn "$ fst $ defaultSettings!!0"
    putStrLn $ fst $ defaultSettings!!0
    putStrLn $ show $ getCode $ snd $ defaultSettings!!0
    putStrLn $ show $ fromJust $ keyCodeFromKeyName "A"
--     chromeStorageSyncSet
--     chromeStorageSyncGet "settings" $ (\d -> putStrLn (showString d))
--     chromeStorageSyncGet "settings" $ (\_ -> putStrLn "UUU")
    localStorageSet "111" "000YYY%%%"
    putStrLn $ localStorageGet "111"

--     putStrLn (showDouble 123)
--     body <- select "body"
--     printArg body
--     addClassWith (\i s -> do putStrLn ("i… " ++ showDouble i)
--                              putStrLn ("s… " ++ showString s)
--                              return "abc")
--                  body
--     addClassWith (\i s -> do putStrLn ("i… " ++ showDouble i)
--                              putStrLn ("s… " ++ showString s)
--                              putStrLn (showString ("def: " ++ s))
--                              return "foo")
--                  body
--     printArg body
    return ()

data JQuery
instance Show JQuery

data Element

printArg :: a -> Fay ()
printArg = ffi "console.log(\"%%o\",%1)"

showDouble :: Double -> String
showDouble = ffi "(%1).toString()"

showString :: String -> String
showString = ffi "JSON.stringify(%1)"

select :: String -> Fay JQuery
select = ffi "jQuery(%1)"

addClassWith :: (Double -> String -> Fay String) -> JQuery -> Fay JQuery
addClassWith = ffi "%2.addClass(%1)"

ready :: Fay () -> Fay ()
ready = ffi "jQuery(%1)"

--
--
--

data Key = Key { getCode :: Int, getCtrl :: Bool, getAlt :: Bool } deriving (Show, Eq)

defaultSettings :: [(String, Key)]
defaultSettings = [
  ("START_HITAHINT",            Key 69  True False),
  ("FOCUS_FORM",                Key 70  True False),
  ("TOGGLE_SELECTOR",           Key 186 True False),
  ("CANCEL",                    Key 27  False False),
  ("MOVE_NEXT_SELECTOR_CURSOR", Key 40  False False),
  ("MOVE_PREV_SELECTOR_CURSOR", Key 38  False False),
  ("MOVE_NEXT_FORM",            Key 34  False False),
  ("MOVE_PREV_FORM",            Key 33  False False),
  ("BACK_HISTORY",              Key 72  True False)
  ]

keyMap :: [(Int, String)]
-- keyMap = [
--   (1, "aa"),
--   (2, "bb")
--   ]
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

keyCodeFromKeyName' :: [(Int, String)] -> String -> Maybe Int
keyCodeFromKeyName' kMap name = listToMaybe [k | (k,v) <- kMap , v == name]

keyCodeFromKeyName :: String -> Maybe Int
keyCodeFromKeyName = keyCodeFromKeyName' keyMap

-- showString :: String -> String
-- showString = ffi "JSON.stringify(%1)"

-- addClassWith :: (Double -> String -> Fay String) -> JQuery -> Fay JQuery
-- addClassWith = ffi "%2.addClass(%1)"

-- chromeStorageSyncGet :: String -> (String -> Fay ()) -> Fay ()
-- chromeStorageSyncGet = ffi "chrome.storage.sync.get(%1, %2)"

-- chromeStorageSyncSet :: Fay ()
-- chromeStorageSyncSet = ffi "chrome.storage.sync.set({\"settings\":\"hogefugabz\"})"

localStorageSet :: String -> String -> Fay ()
localStorageSet = ffi "localStorage.setItem(%1, %2)"

localStorageGet :: String -> String
localStorageGet = ffi "localStorage.getItem(%1)"

ctrlKeycode :: Int
ctrlKeycode = 17
altKeycode :: Int
altKeycode = 18

-- data itemType = Tab | History | Bookmark | Websearch | Command
selectorNum :: Int
selectorNum = 20

-- WEB_SEARCH_LIST =
--   {title: 'google検索', url: 'https://www.google.co.jp/#hl=ja&q=', type: 'websearch'}
--   {title: 'alc辞書', url: 'http://eow.alc.co.jp/search?ref=sa&q=', type: 'websearch'}

formInputFields :: String
formInputFields = "input[type=\"text\"]:not(\"#selectorInput\"), textarea, select"
clickables :: String
clickables = "a"
-- CLICKABLES = "a[href],input:not([type=hidden]),textarea,select,*[onclick],button"

_hintKeys :: [(Int, String)]
_hintKeys = [(65, "A"), (66, "B"), (67, "C"), (68, "D"), (69, "E"), (70, "F"), (71, "G"), (72, "H"), (73, "I"), (74, "J"), (75, "K"), (76, "L"), (77, "M"), (78, "N"), (79, "O"), (80, "P"), (81, "Q"), (82, "R"), (83, "S"), (84, "T"), (85, "U"), (86, "V"), (87, "W"), (88, "X"), (89, "Y"), (90, "Z")]
hintKeys :: [(Int, String)]
hintKeys =  [(i1*100+i2, s1 ++ s2)|(i1, s1) <- _hintKeys, (i2, s2) <- _hintKeys]


keyCodeToIndex :: Int -> Int -> Maybe Int
keyCodeToIndex firstKeyCode secondKeyCode = elemIndex (firstKeyCode*100+secondKeyCode) $ map fst hintKeys

-- # インデックスを受取り、HintKeyのリストの中から対応するキーコードを返す
indexToKeyCode :: Int -> Maybe Int
indexToKeyCode index
  | length hintKeys > index = Just $ fst $ hintKeys!!index
  | otherwise = Nothing

-- # キーコードを受取り、それがHintKeyかどうかを返す
isHitAHintKey :: Int -> Bool
isHitAHintKey keyCode = elem keyCode $ map fst _hintKeys

-- # 現在フォーカスがある要素がtextタイプのinputかtextareaである(文字入力可能なformの要素)かどうかを返す
-- isFocusingForm :: Fay Bool
-- isFocusingForm = do
--   focusElems <- select ":focus"

--   console.log('isFocusingForm')
--   focusElems = $(':focus')
--   console.log(focusElems.attr('type'))
--   focusElems[0] and (
--     (focusElems[0].nodeName.toLowerCase() == "input" and focusElems.attr('type') == "text") or
--     focusElems[0].nodeName.toLowerCase() == "textarea"
--   )

data Item = Item { getId :: String, getTitle :: String, getUrl :: String, getType :: String } deriving (Show)

-- # (tab|history|bookmark|,,,)のリストをうけとりそれをhtmlにしてappendする
makeSelectorConsole :: [Item] -> Fay JQuery
makeSelectorConsole items = do
  selectorList <- select "#selectorList"
  remove selectorList
  selectorConsole <- select "#selectorConsole"
  append ts selectorConsole
  firstSelectorElem <- select "#selectorList tr:first"
  addClass "selected" firstSelectorElem
  where
    num = 20
    trs = ["<tr id=\"" ++ getType t ++ "-" ++ getId t ++ "\"><td><span class=\"title\">["++ getType t ++ "] " ++ getTitle t ++ " </span><span class=\"url\"> " ++ getUrl t ++ "</span></td></tr>" | t <- items]
    ts = "<table id=\"selectorList\">" ++ concat(take num trs) ++ "</table>"

remove :: JQuery -> Fay JQuery
remove = ffi "%1.remove()"

append :: String -> JQuery -> Fay JQuery
append = ffi "%2.append(%1)"

addClass :: String -> JQuery -> Fay JQuery
addClass = ffi "%2.addClass(%1)"

-- chromeStorageSyncGet :: String -> (String -> Fay ()) -> Fay ()
-- chromeStorageSyncGet = ffi "chrome.storage.sync.get(%1, %2)"

-- chromeStorageSyncSet :: String -> Fay ()
-- chromeStorageSyncSet = ffi "chrome.storage.sync.set(JSON.parse(%1))"

keyMapper :: Key -> [(String, Key)] -> Maybe String
keyMapper key settings = listToMaybe $ map fst $ filter ((== key) . snd) settings

data Mode = NeutralMode | HitAHintMode | SelectorMode | FormFocusMode deriving (Show)
data Event

getKeyCode :: Event -> Int
getKeyCode = ffi "%1.keyCode"

keyupMap :: Event -> (Mode, Bool, Bool) -> Fay (Mode, Bool, Bool)
keyupMap e (SelectorMode, ctrl, alt) = do
  case getKeyCode e of
    ctrlKeyCode -> return (SelectorMode, False, alt)
    altKeyCode  -> return (SelectorMode, ctrl, False)
    otherwise   -> filterSelector e
keyupMap e (FormFocusMode, ctrl, alt) = do
  case getKeyCode e of
    ctrlKeyCode -> return (FormFocusMode, False, alt)
    altKeyCode  -> return (FormFocusMode, ctrl, False)
    otherwise   -> do
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just "MOVE_NEXT_FORM" -> focusNextForm e
        Just "MOVE_PREV_FORM" -> focusPrevForm e
        Just "CANCEL"         -> cancel e
        _ -> return (NeutralMode, ctrl, alt)
keyupMap e (mode, ctrl, alt) = do
  case getKeyCode e of
    ctrlKeyCode -> return (mode, False, alt)
    altKeyCode  -> return (mode, ctrl, False)
    otherwise   -> return (mode, ctrl, alt)

startHah = undefined
focusForm = undefined
toggleSelector = undefined
filterSelector = undefined
focusNextForm = undefined
focusPrevForm = undefined
cancel = undefined
hitHintKey = undefined

keydownMap :: Event -> (Mode, Bool, Bool) -> Fay (Mode, Bool, Bool)
keydownMap e (NeutralMode, ctrl, alt) = do
  case getKeyCode e of
    ctrlKeyCode -> return (NeutralMode, True, alt)
    altKeyCode  -> return (NeutralMode, ctrl, True)
    otherwise   -> do
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just "START_HITAHINT"  -> startHah e
        Just "FOCUS_FORM"      -> focusForm e
        Just "TOGGLE_SELECTOR" -> toggleSelector e
        _ -> return (NeutralMode, ctrl, alt)
keydownMap e (HitAHintMode, ctrl, alt) = do
  case getKeyCode e of
    ctrlKeyCode -> return (HitAHintMode, True, alt)
    altKeyCode  -> return (HitAHintMode, ctrl, True)
    otherwise   -> do
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just "CANCEL" -> cancel
        _ -> if isHitAHintKey (getKeyCode e)
             then hitHintKey e
             else return (HitAHintMode, ctrl, alt)
keydownMap e (mode, ctrl, alt) = do
  case getKeyCode e of
    ctrlKeyCode -> return (mode, True, alt)
    altKeyCode  -> return (mode, ctrl, True)
    otherwise   -> return (mode, ctrl, alt)


keyup :: (Event -> Fay (Mode, Bool, Bool)) -> Fay (Mode, Bool, Bool)
keyup = ffi "$(document).keyup(%1)"
keydown :: (Event -> Fay (Mode, Bool, Bool)) -> Fay (Mode, Bool, Bool)
keydown = ffi "$(document).keydown(%1)"


on :: String -> String -> (Event -> Fay ()) -> JQuery -> Fay JQuery
on = ffi "%4.on(%1, %2, %3)"

start' :: (Mode, Bool, Bool) -> Fay ()
start' (mode, ctrl, alt) = do
  body <- select "body"
  keydown (\e -> keydownMap e (mode, ctrl, alt))
  keyup (\e -> keyupMap e (mode, ctrl, alt))
  on "submit" "#selectorForm" decideSelector body
--   on "focus" formInputFields (\_ -> )
--   on "blur" formInputFields (\_ -> )
  return ()

decideSelector :: Event -> Fay ()
decideSelector e = do
  preventDefault e
  --
  --
  --
  return ()

preventDefault :: Event -> Fay ()
preventDefault = ffi "%1.preventDefault()"

{--

--}