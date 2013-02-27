{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module ChromeExtFay where

import Prelude
import FFI

import MyPrelude

main :: Fay ()
main = do
  ready $ do
--     chromeExtensionSendMessage "{\"mes\": \"makeSelectorConsole\"}" (\is -> putStrLn "chromeExtensionSendMessage")
    putStrLn $ show $ keyMapper (Key 80 True False) defaultSettings
    putStrLn $ show $ keyMapper (Key 186 True False) defaultSettings
    start
--     modeRef <- newRef NeutralMode
--     mode <- readRef modeRef
--     putStrLn $ show $ mode
--     writeRef modeRef HitAHintMode
--     mode1 <- readRef modeRef
--     putStrLn $ show $ mode1

--     chromeStorageSyncSet "{\"aahoge\":\"XX12345\"}"
--     chromeStorageSyncGet "aahoge" (\d -> do{putStrLn "aahoge";putStrLn (showString d)})

--     body <- select "body"
--     append "<div id=\"selectorConsole\"><form id=\"selectorForm\"><input id=\"selectorInput\" type=\"text\" /></form></div>" body
--     makeSelectorConsole ([(Item "id00" "title00" "url00" "type00"),(Item "id01" "title01" "url01" "type01")])
--     putStrLn $ snd $ hintKeys!!0
--     putStrLn $ snd $ hintKeys!!110
--     putStrLn $ show $ fst $ hintKeys!!1
--     putStrLn $ show $ fromJust $ keyCodeToIndex 69 71
--     putStrLn $ show $ fromJust $ indexToKeyCode 110
--     putStrLn $ show $ isHitAHintKey 70
--     putStrLn $ show $ isHitAHintKey 7
--     putStrLn "$ fst $ defaultSettings!!0"
--     putStrLn $ fst $ defaultSettings!!0
--     putStrLn $ show $ getCode $ snd $ defaultSettings!!0
--     putStrLn $ show $ fromJust $ keyCodeFromKeyName "A"
-- --     chromeStorageSyncSet
-- --     chromeStorageSyncGet "settings" $ (\d -> putStrLn (showString d))
-- --     chromeStorageSyncGet "settings" $ (\_ -> putStrLn "UUU")
--     localStorageSet "111" "000YYY%%%"
--     putStrLn $ localStorageGet "111"

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
  putStrLn "makeSelectorConsole"
  putStrLn $ show $ length items
  putStrLn $ show $ (items!!0)
--   putStrLn ts
  select "#selectorList" >>= remove
  select "#selectorConsole" >>= append ts
  select "#selectorList tr:first" >>= addClass "selected"
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


keyupMap :: Event -> St -> Fay ()
keyupMap e (St modeRef ctrlRef altRef _ _) = do
  putStrLn $ "keyupMap: " ++ (show $ getKeyCode e)
  case getKeyCode e of
--     ctrlKeyCode -> writeRef ctrlRef False
--     altKeyCode  -> writeRef altRef False
    17 -> do
      putStrLn "ctrlKeyCode"
      writeRef ctrlRef False
    18  -> do
      putStrLn "altKeyCode"
      writeRef altRef False
    _           -> do
      mode <- readRef modeRef
      putStrLn $ show mode
      keyupMap' e mode ctrlRef altRef
  return ()
  where
    keyupMap' :: Event -> Mode -> Ref Bool -> Ref Bool -> Fay ()
    keyupMap' e SelectorMode ctrlRef altRef = filterSelector $ getKeyCode e
    keyupMap' e FormFocusMode ctrlRef altRef = do
      putStrLn "keyupMap'"
      ctrl <- readRef ctrlRef
      alt <- readRef altRef
      putStrLn $ show ctrl
      putStrLn $ show alt
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just "MOVE_NEXT_FORM" -> focusNextForm e
        Just "MOVE_PREV_FORM" -> focusPrevForm e
        Just "CANCEL"         -> cancel e
        a -> do
          putStrLn $ show a
          putStrLn $ show $ Key (getKeyCode e) ctrl alt
          putStrLn $ show $ keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings
          return ()
    keyupMap' _ _ _ _ = return ()

keydownMap :: Event -> St -> Fay ()
keydownMap e (St modeRef ctrlRef altRef inputIdxRef _) = do
  putStrLn $ "keydownMap: " ++ (show $ getKeyCode e)
  case getKeyCode e of
--     ctrlKeyCode -> writeRef ctrlRef True
--     altKeyCode  -> writeRef altRef True
    17 -> do
      putStrLn "ctrlKeyCode"
      writeRef ctrlRef True
    18  -> do
      putStrLn "altKeyCode"
      writeRef altRef True
    _           -> do
      mode <- readRef modeRef
      putStrLn $ show mode
      keydownMap' e mode ctrlRef altRef
  return ()
  where
    keydownMap' :: Event -> Mode -> Ref Bool -> Ref Bool -> Fay ()
    keydownMap' e NeutralMode ctrlRef altRef = do
      putStrLn "keydownMap'"
      ctrl <- readRef ctrlRef
      alt <- readRef altRef
      putStrLn $ show ctrl
      putStrLn $ show alt
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just "START_HITAHINT"  -> startHah modeRef
        Just "FOCUS_FORM"      -> focusForm modeRef inputIdxRef
        Just "TOGGLE_SELECTOR" -> toggleSelector modeRef
        a -> do
          putStrLn $ show a
          putStrLn $ show $ Key (getKeyCode e) ctrl alt
          putStrLn $ show $ keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings
          return ()
    keydownMap' e HitAHintMode ctrlRef altRef = do
      ctrl <- readRef ctrlRef
      alt <- readRef altRef
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just "CANCEL" -> cancel e
        _ -> if isHitAHintKey (getKeyCode e)
             then hitHintKey e
             else return ()
    keydownMap' _ _ _ _ = return ()

keyup :: (Event -> Fay ()) -> Fay ()
keyup = ffi "$(document).keyup(%1)"
keydown :: (Event -> Fay ()) -> Fay ()
keydown = ffi "$(document).keydown(%1)"


startHah :: Ref Mode -> Fay ()
startHah modeRef = do
  putStrLn "startHah"
  writeRef modeRef HitAHintMode
  select clickables >>= addClass "links" >>= jqHtml f
  return ()
  where
    f (i, oldHtml) = case indexToKeyCode i of
      Just keyCode -> case lookup keyCode hintKeys of
        Just hintKeyName -> "<div class=\"hintKey\">" ++ hintKeyName ++ "</div> " ++ oldHtml
        _ -> oldHtml
      _ -> oldHtml
--     f (i, oldHtml) = case lookup (indexToKeyCode i) hintKeys of
--       Just hintKeyName -> "<div class=\"hintKey\">" + hintKeyName + "</div> " ++ oldHtml
--       _ -> oldHtml

focusForm :: Ref Mode -> Ref Int -> Fay ()
focusForm modeRef inputIdxRef = do
  putStrLn "focusForm"
  writeRef modeRef FormFocusMode
  writeRef inputIdxRef 0
  inputFields <- select formInputFields
  jqEq 0 inputFields >>= jqFocus
  return ()

toggleSelector :: Ref Mode -> Fay ()
toggleSelector modeRef = do
  putStrLn "toggleSelector"
  writeRef modeRef SelectorMode
  console <- select "#selectorConsole"
  jqShow console
  input <- select "#selectorInput"
  jqFocus input
  return ()

filterSelector keyCode = do
  putStrLn "filterSelector"

focusNextForm = undefined
focusPrevForm = undefined
cancel = undefined
hitHintKey = undefined

jqHtml :: ((Int, String) -> a) -> JQuery -> Fay JQuery
jqHtml = ffi "%2.html(f)"

jqEq :: Int -> JQuery -> Fay JQuery
jqEq = ffi "%2.eq(%1)"

jqShow :: JQuery -> Fay JQuery
jqShow = ffi "%1.show()"
jqFocus :: JQuery -> Fay JQuery
jqFocus = ffi "%1.focus()"

on :: String -> String -> (Event -> Fay ()) -> JQuery -> Fay JQuery
on = ffi "%4.on(%1, %2, %3)"

data St = St {
    getModeRef :: Ref Mode
  , getCtrlRef :: Ref Bool
  , getAltRef :: Ref Bool
  , getInputIdxRef :: Ref Int
  , getListRef :: Ref [Item]
  }

start :: Fay ()
start = do
  modeRef <- newRef NeutralMode
  ctrlRef <- newRef False
  altRef <- newRef False
  inputIdxRef <- newRef 0
  listRef <- newRef []
  let st = St { getModeRef = modeRef
              , getCtrlRef = ctrlRef
              , getAltRef = altRef
              , getInputIdxRef = inputIdxRef
              , getListRef = listRef
              }
  body <- select "body"
  keydown (\e -> keydownMap e st)
  keyup (\e -> keyupMap e st)
  on "submit" "#selectorForm" decideSelector body
  on "focus" formInputFields (\_ -> writeRef modeRef FormFocusMode) body
  on "blur" formInputFields (\_ -> writeRef modeRef NeutralMode) body

  chromeExtensionSendMessage "{\"mes\": \"makeSelectorConsole\"}" $ \is -> do
    putStrLn "extension.sendMessage"
--     putStrLn $ show (is!!0)
    putStrLn $ show is
--     putStrLn "---"
--     putStrLn is
--     items <- toItemsfromJSON is
    items <- toItemsfromJSON $ show is
    writeRef listRef items
    select "body" >>= append "<div id=\"selectorConsole\"><form id=\"selectorForm\"><input id=\"selectorInput\" type=\"text\" /></form></div>"
    makeSelectorConsole items
--     makeSelectorConsole $ map (\i -> Item { getId = (id i), getTitle = (title i), getUrl = (url i), getType = (type i)) is
    return ()

--   isFocusingForm then writeRef modeRef FormFocusMode else Fay ()
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


data Ref a

newRef :: a -> Fay (Ref a)
newRef = ffi "new Fay$$Ref(%1)"

writeRef :: Ref a -> a -> Fay ()
writeRef = ffi "Fay$$writeRef(%1,%2)"

readRef :: Ref a -> Fay a
readRef = ffi "Fay$$readRef(%1)"

chromeExtensionSendMessage :: String -> (a -> Fay ()) -> Fay ()
chromeExtensionSendMessage = ffi "chrome.extension.sendMessage(JSON.parse(%1), %2)"

-- { getId :: String, getTitle :: String, getUrl :: String, getType :: String }
-- getItemFromJSON :: a -> (String, String, String, String)
-- getItemFromJSON = ffi "%1.id,

-- jsonParse :: String -> Fay a
-- jsonParse = ffi "JSON.stringify(%1)"

toItemsfromJSON :: String -> Fay [Item]
toItemsfromJSON = ffi "JSON.parse(%1)"

{--

--}