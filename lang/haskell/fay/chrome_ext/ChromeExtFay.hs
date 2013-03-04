{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module ChromeExtFay where

import Prelude
import FFI
import MyPrelude
import Hah.Types
import Hah.Configs
import JS
import ChromeExt

main :: Fay ()
main = do
  ready $ do
    putStrLn "[2013-03-04 12:38]"
    start
    return ()

keyCodeFromKeyName' :: [(Int, String)] -> String -> Maybe Int
keyCodeFromKeyName' kMap name = listToMaybe [k | (k,v) <- kMap , v == name]

keyCodeFromKeyName :: String -> Maybe Int
keyCodeFromKeyName = keyCodeFromKeyName' keyMap

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

makeSelectorConsole :: String -> Fay JQuery
makeSelectorConsole htmlStr = do
  putStrLn "makeSelectorConsole"
  putStrLn htmlStr
  htmlStr' <- arrToStr htmlStr
  putStrLn htmlStr'
  select "#selectorList" >>= remove
  select "#selectorConsole" >>= append htmlStr'
  select "#selectorList tr:first" >>= addClass "selected"

makeSelectorConsole' :: [Item] -> Fay JQuery
makeSelectorConsole' items = do
  putStrLn "makeSelectorConsole'"
  trList <- arrToStr $ concatMap makeTrList items
  putStrLn "trList"
  putStrLn trList
  jqTable <- select "table" >>= setAttr "id" "selectorList" >>= append trList
--   jqTable <- select "table"
--   setAttr "id" "selectorList" jqTable
--   append trList jqTable
--   putStrLn $ show jqTable
  select "#selectorList" >>= remove
  select "#selectorConsole" >>= appendJ jqTable
  select "#selectorList tr:first" >>= addClass "selected"
  where
    makeTrList :: Item -> String
    makeTrList item = arrToStr' $ concat ["<tr itemType=", show (getType item), " itemId=", show (getId item), "><td><span class=\"title\">[" , show (getType item), "] ", show (getTitle item), " </span><span class=\"url\"> ", show (getUrl item), "</span></td></tr>"]
--     items' <- arrToStr $ "<table id=\"selectorList\">" ++ concat ["<tr id=\"" ++ show (getType t) ++ "-" ++ show (getId t) ++ "\"><td><span class=\"title\">[" ++ show (getType t) ++ "] " ++ show (getTitle t) ++ " </span><span class=\"url\"> " ++ show (getUrl t) ++ "</span></td></tr>" | t <- (take 10 items)] ++ "</table>"

--     makeTrList :: Item -> Fay JQuery
--     makeTrList item = do
--       let title = getTitle item
--           id = getId item
--           typ = getType item
--           url = getUrl item
--       jqTr <- select "tr" >>= setAttr "id" $ typ ++ id
--       jqTd <- append "td" jqTr
--       append "span" jqTd >>= addClass "title" >>= jqText $ "[" ++ typ ++ "]" ++ title
--       append "span" jqTd >>= addClass "url" >>= jqText url
--       jqTr

-- makeSelectorConsole'' :: [a] -> Fay ()
-- makeSelectorConsole'' = ffi "function(%1){ var ts, t; if ($('#selectorList')) { $('#selectorList').remove(); } console.log(%1); ts = p.concat(p.take(20, (function(){ var i$, ref$, len$, results$ = []; for (i$ = 0, len$ = (ref$ = %1).length; i$ < len$; ++i$) { t = ref$[i$]; results$.push('<tr id=\"' + t.type + '-' + t.id + '\"><td><span class=\"title\">[' + t.type + '] ' + t.title + ' </span><span class=\"url\"> ' + t.url + '</span></td></tr>'); } return results$; }()))); $('#selectorConsole').append('<table id=\"selectorList\">' + ts + '</table>'); return $('#selectorList tr:first').addClass('selected'); }();"

keyMapper :: Key -> [(String, Key)] -> Maybe String
keyMapper key settings = listToMaybe $ map fst $ filter ((== key) . snd) settings

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

cancel :: Ref Mode -> Ref (Maybe Int) -> Event -> Fay ()
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


moveNextCursor :: Event -> Fay ()
moveNextCursor e = do
  putStrLn "moveNextCursor"
  preventDefault e
  select "#selectorList .selected" >>= jqRemoveClass "selected" >>= jqNext "tr" >>= addClass "selected"
  return ()

movePrevCursor :: Event -> Fay ()
movePrevCursor e = do
  putStrLn "movePrevCursor"
  preventDefault e
  select "#selectorList .selected" >>= jqRemoveClass "selected" >>= jqPrev "tr" >>= addClass "selected"
  return ()

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
  on "submit" "#selectorForm" (\e -> decideSelector modeRef firstKeyCodeRef listRef e) body
  on "focus" formInputFields (\_ -> writeRef modeRef FormFocusMode) body
  on "blur" formInputFields (\_ -> writeRef modeRef NeutralMode) body

  chromeExtensionSendMessage "{\"mes\": \"makeSelectorConsole\"}" $ \is -> do
    putStrLn "extension.sendMessage"
    items <- fromJSON $ show is
    writeRef listRef items
    select "body" >>= append "<div id=\"selectorConsole\"><form id=\"selectorForm\"><input id=\"selectorInput\" type=\"text\" /></form></div>"
    items' <- arrToStr $ "<table id=\"selectorList\">" ++ concat ["<tr itemType=" ++ show (getType t) ++ " itemId=" ++ show (getId t) ++ "><td><span class=\"title\">[" ++ show (getType t) ++ "] " ++ show (getTitle t) ++ " </span><span class=\"url\"> " ++ show (getUrl t) ++ "</span></td></tr>" | t <- (take 10 items)] ++ "</table>"
    makeSelectorConsole items'
--     makeSelectorConsole' items
    return ()

  isFocus <- isFocusingForm
  if isFocus then writeRef modeRef FormFocusMode else return ()

  return ()

decideSelector :: Ref Mode -> Ref (Maybe Int) -> Ref [Item] -> Event -> Fay ()
decideSelector modeRef firstKeyCodeRef listRef e = do
  putStrLn "decideSelector"
  preventDefault e
  (typ, id) <- getTypeAndId
  url <- select "#selectorList tr.selected span.url" >>= jqText
  query <- select "#selectorInput" >>= jqVal
  putStrLn $ typ ++ ":" ++ id ++ ":" ++ url ++ ":" ++ query
  cancel modeRef firstKeyCodeRef e
--   chromeExtensionSendMessage (jsonStr id typ url query) $ \list -> do
--     putStrLn "decideSelector callback"
-- --     items <- fromJSON $ show list
-- --     writeRef listRef items
-- --     items' <- arrToStr $ concatMap show items
-- --     makeSelectorConsole items'
--     return ()
  select "#selectorInput" >>= jqVal
  return ()
  where
    getTypeAndId :: Fay (String, String)
    getTypeAndId = do
      j <- select "#selectorList tr.selected"
      return $ (attr "itemtype" j, attr "itemid" j)

    jsonStr :: String -> String -> String -> String -> String
    jsonStr id typ url query = "{\"mes\": \"decideSelector\", \"item\":{\"id\":\"" ++ id ++ "\", \"url\":\"" ++ url ++ "\", \"type\":\"" ++ typ ++ "\", \"query\":\"" ++ query ++ "\"}"

-- fromJSON :: String -> Fay [Item]
fromJSON :: String -> Fay [a]
fromJSON = ffi "JSON.parse(%1)"
