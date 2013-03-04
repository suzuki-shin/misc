{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module ChromeExtFay where

import Prelude
import FFI
import MyPrelude
import JS

main :: Fay ()
main = do
  ready $ do
    putStrLn "[2013-03-04 10:42]"
    start
    return ()

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
isFocusingForm :: Fay Bool
isFocusingForm = do
  focusElems <- select ":focus"
  elm <- jqIdx 0 focusElems
  let lowerNodeName = toLowerCase $ nodeName elm
      typeAttr = attr "type" focusElems
  return $ (lowerNodeName == "input" && typeAttr == "text") || lowerNodeName == "textarea"

data Item = Item { getId :: String, getTitle :: String, getUrl :: String, getType :: String } deriving (Show)

makeSelectorConsole :: String -> Fay JQuery
makeSelectorConsole htmlStr = do
  putStrLn "makeSelectorConsole"
  select "#selectorList" >>= remove
  select "#selectorConsole" >>= append htmlStr
  select "#selectorList tr:first" >>= addClass "selected"

keyMapper :: Key -> [(String, Key)] -> Maybe String
keyMapper key settings = listToMaybe $ map fst $ filter ((== key) . snd) settings

data Mode = NeutralMode | HitAHintMode | SelectorMode | FormFocusMode deriving (Show)

keyupMap :: Event -> St -> Fay ()
keyupMap e (St modeRef ctrlRef altRef _ _ firstKeyCodeRef) = do
  putStrLn $ "keyupMap: " ++ (show $ getKeyCode e)
  case getKeyCode e of
--     ctrlKeyCode -> writeRef ctrlRef False
--     altKeyCode  -> writeRef altRef False
    17 -> do
      putStrLn "ctrlKeyCode"
      writeRef ctrlRef False
    18 -> do
      putStrLn "altKeyCode"
      writeRef altRef False
    _ -> do
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
        Just "CANCEL"         -> cancel modeRef firstKeyCodeRef e
        a -> do
          putStrLn $ show a
          putStrLn $ show $ Key (getKeyCode e) ctrl alt
          putStrLn $ show $ keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings
          return ()
    keyupMap' _ _ _ _ = return ()

keydownMap :: Event -> St -> Fay ()
keydownMap e (St modeRef ctrlRef altRef inputIdxRef _ firstKeyCodeRef) = do
  putStrLn $ "keydownMap: " ++ (show $ getKeyCode e)
  case getKeyCode e of
--     ctrlKeyCode -> writeRef ctrlRef True
--     altKeyCode  -> writeRef altRef True
    17 -> do
      putStrLn "ctrlKeyCode"
      writeRef ctrlRef True
    18 -> do
      putStrLn "altKeyCode"
      writeRef altRef True
    _ -> do
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
        Just "CANCEL" -> cancel modeRef firstKeyCodeRef e
        _ -> if isHitAHintKey (getKeyCode e)
             then hitHintKey modeRef firstKeyCodeRef e
             else return ()
    keydownMap' e SelectorMode ctrlRef altRef = do
      ctrl <- readRef ctrlRef
      alt <- readRef altRef
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just "MOVE_NEXT_SELECTOR_CURSOR" -> moveNextCursor e
        Just "MOVE_PREV_SELECTOR_CURSOR" -> movePrevCursor e
        Just "CANCEL" -> cancel modeRef firstKeyCodeRef e
        _ -> return ()
    keydownMap' _ _ _ _ = return ()

startHah :: Ref Mode -> Fay ()
startHah modeRef = do
  putStrLn "startHah"
  writeRef modeRef HitAHintMode
  select clickables >>= addClass "links" >>= jqHtml addHintKeyChip
  return ()
  where
    addHintKeyChip i oldHtml = case indexToKeyCode i of
      Just keyCode -> case lookup keyCode hintKeys of
        Just hintKeyName -> "<div class=\"hintKey\">" ++ hintKeyName ++ "</div> " ++ oldHtml
        _ -> oldHtml
      _ -> oldHtml

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
-- focusNextForm :: Event -> Ref Int -> Fay ()
-- focusNextForm e inputIdxRef = do
--   preventDefault e
--   idx <- readRef inputIdxRef
--   writeRef inputIdxRef $ idx + 1

--       e.preventDefault()
--       console.log('focusNextForm')
--       Main.formInputFieldIndex += 1
--       console.log(Main.formInputFieldIndex)
--       console.log($(FORM_INPUT_FIELDS))
--       console.log($(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex))
--       if $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex)?
--         $(FORM_INPUT_FIELDS).eq(Main.formInputFieldIndex).focus()


focusPrevForm = undefined

cancel modeRef firstKeyCodeRef event = do
  preventDefault event
  readRef modeRef >>= cancel'
--   mode <- readRef modeRef
--   cancel' mode
  writeRef modeRef NeutralMode
  where
    cancel' SelectorMode = do
      putStrLn "SelectorMode cancel"
      select "#selectorConsole" >>= jqHide
      select ":focus" >>= jqBlur
      return ()
    cancel' HitAHintMode = do
      putStrLn "HitAHintMode cancel"
      writeRef firstKeyCodeRef Nothing
      select clickables >>= jqRemoveClass "links"
      select ".hintKey" >>= jqRemove
      return ()
    cancel' _ = select ":focus" >>= jqBlur >> return ()

hitHintKey modeRef firstKeyCodeRef event = do
  mFirstKeyCode <- readRef firstKeyCodeRef
  case mFirstKeyCode of
    Just firstKeyCode -> do
      preventDefault event
      putStrLn $ "hit: " ++ show (getKeyCode event) ++ ", 1stkey: " ++ show firstKeyCode
      case keyCodeToIndex firstKeyCode (getKeyCode event) of
        Just idx -> do
          writeRef modeRef NeutralMode
          writeRef firstKeyCodeRef Nothing
          select clickables >>= jqIdx idx >>= jqClick >>= jqRemoveClass "links"
          select ".hintKey" >>= jqRemove
          return ()
        _ -> return ()
    Nothing -> do
      writeRef firstKeyCodeRef $ Just $ getKeyCode event
  return ()


moveNextCursor = undefined
movePrevCursor = undefined

data St = St {
    getModeRef :: Ref Mode
  , getCtrlRef :: Ref Bool
  , getAltRef :: Ref Bool
  , getInputIdxRef :: Ref Int
  , getListRef :: Ref [Item]
  , getFirstKeyCodeRef :: Ref (Maybe Int)
  }

start :: Fay ()
start = do
  modeRef <- newRef NeutralMode
  ctrlRef <- newRef False
  altRef <- newRef False
  inputIdxRef <- newRef 0
  listRef <- newRef []
  firstKeyCodeRef <- newRef Nothing
  let st = St { getModeRef = modeRef
              , getCtrlRef = ctrlRef
              , getAltRef = altRef
              , getInputIdxRef = inputIdxRef
              , getListRef = listRef
              , getFirstKeyCodeRef = firstKeyCodeRef
              }
  body <- select "body"
  keydown (\e -> keydownMap e st)
  keyup (\e -> keyupMap e st)
  on "submit" "#selectorForm" decideSelector body
  on "focus" formInputFields (\_ -> writeRef modeRef FormFocusMode) body
  on "blur" formInputFields (\_ -> writeRef modeRef NeutralMode) body

  chromeExtensionSendMessage "{\"mes\": \"makeSelectorConsole\"}" $ \is -> do
    putStrLn "extension.sendMessage"
    items <- fromJSON $ show is
    writeRef listRef items
    select "body" >>= append "<div id=\"selectorConsole\"><form id=\"selectorForm\"><input id=\"selectorInput\" type=\"text\" /></form></div>"
    items' <- arrToStr $ "<table id=\"selectorList\">" ++ concat ["<tr id=\"" ++ show (getType t) ++ "-" ++ show (getId t) ++ "\"><td><span class=\"title\">[" ++ show (getType t) ++ "] " ++ show (getTitle t) ++ " </span><span class=\"url\"> " ++ show (getUrl t) ++ "</span></td></tr>" | t <- (take 10 items)] ++ "</table>"
    makeSelectorConsole items'
    return ()

  isFocus <- isFocusingForm
  if isFocus then writeRef modeRef FormFocusMode else return ()

  return ()

decideSelector :: Event -> Fay ()
decideSelector e = do
  preventDefault e
  --
  --
  --
  return ()

fromJSON :: String -> Fay [Item]
fromJSON = ffi "JSON.parse(%1)"
