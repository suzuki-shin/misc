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
    putStrLn "[2013-03-05 15:29]"
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
  | otherwise               = Nothing

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

makeSelectorConsole :: [Item] -> Fay JQuery
makeSelectorConsole items = do
  putStrLn "makeSelectorConsole"
  htmlStr <- arrToStr $ "<table id=\"selectorList\">" ++ concat ["<tr itemType=" ++ show (getType t) ++ " itemId=" ++ show (getId t) ++ "><td><span class=\"title\">[" ++ show (getType t) ++ "] " ++ show (getTitle t) ++ " </span><span class=\"url\"> " ++ show (getUrl t) ++ "</span></td></tr>" | t <- (take 10 items)] ++ "</table>"
--   putStrLn htmlStr
  select "#selectorList" >>= remove
  select "#selectorConsole" >>= append htmlStr
  select "#selectorList tr:first" >>= addClass "selected"

keyMapper :: Key -> [(Method, Key)] -> Maybe Method
keyMapper key settings = listToMaybe $ map fst $ filter ((== key) . snd) settings

keyupMap :: Event -> St -> Fay ()
keyupMap e (St modeRef ctrlRef altRef _ listRef firstKeyCodeRef) = do
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
    keyupMap' e SelectorMode ctrlRef altRef = filterSelector listRef $ getKeyCode e
    keyupMap' e FormFocusMode ctrlRef altRef = do
      putStrLn "keyupMap'"
      ctrl <- readRef ctrlRef
      alt <- readRef altRef
      putStrLn $ show ctrl
      putStrLn $ show alt
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just MoveNextForm -> focusNextForm e
        Just MovePrevForm -> focusPrevForm e
        Just Cancel         -> cancel modeRef firstKeyCodeRef e
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
        Just StartHitahint  -> startHah modeRef
        Just FocusForm      -> focusForm modeRef inputIdxRef
        Just ToggleSelector -> toggleSelector modeRef
        a -> do
          putStrLn $ show a
          putStrLn $ show $ Key (getKeyCode e) ctrl alt
          putStrLn $ show $ keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings
          return ()
    keydownMap' e HitAHintMode ctrlRef altRef = do
      ctrl <- readRef ctrlRef
      alt <- readRef altRef
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just Cancel -> cancel modeRef firstKeyCodeRef e
        _ -> if isHitAHintKey (getKeyCode e)
             then hitHintKey modeRef firstKeyCodeRef e
             else return ()
    keydownMap' e SelectorMode ctrlRef altRef = do
      ctrl <- readRef ctrlRef
      alt <- readRef altRef
      case keyMapper (Key (getKeyCode e) ctrl alt) defaultSettings of
        Just MoveNextSelectorCursor -> moveNextCursor e
        Just MovePrevSelectorCursor -> movePrevCursor e
        Just Cancel -> cancel modeRef firstKeyCodeRef e
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

filterSelector :: Ref [Item] -> Int -> Fay ()
filterSelector listRef keyCode = do
  putStrLn "filterSelector"
  putStrLn $ show keyCode
  case elem keyCode [65..90] of
    False -> return ()
    True -> do
      putStrLn "filterSelector 2"
      text <- select "#selectorInput" >>= jqVal
      list <- readRef listRef
      let list' = filtering text list
      makeSelectorConsole list'
--       makeSelectorConsole filtering(text, Main.list).concat(WEB_SEARCH_LIST)
      select "#selectorConsole" >>= jqShow
      return ()
  where
    -- # 受け取ったテキストをスペース区切りで分割して、その要素すべてが(tab|history|bookmark)のtitleかtabのurlに含まれるtabのみ返す
    filtering :: String -> [Item] -> [Item]
    filtering text list = filter (\t -> matchP t (words text)) list
    -- queriesのすべての要素がtitleかurlに見つかるかどうかを返す
    matchP :: Item -> [String] -> Bool
    matchP item queries = all id [(toLowerCase q) `isInfixOf` (toLowerCase (show (getTitle item))) || (toLowerCase q) `isInfixOf` (toLowerCase (show (getUrl item))) | q <- queries]

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
  select "#selectorConsole" >>= jqHide
  select ":focus" >>= jqBlur
  select clickables >>= jqRemoveClass "links"
  select ".hintKey" >>= jqRemove
  writeRef firstKeyCodeRef Nothing
  writeRef modeRef NeutralMode

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
    items <- toItemsfromJSON $ show is
--     putStrLn $ show $ items
    writeRef listRef items
    select "body" >>= append "<div id=\"selectorConsole\"><form id=\"selectorForm\"><input id=\"selectorInput\" type=\"text\" /></form></div>"
    makeSelectorConsole items

    -----------------
    -----------------
--     hoge <- readRef listRef
--     putStrLn "--------- hoge ---------"
--     putStrLn $ show $ length hoge -- 235
--     putStrLn $ show $ hoge!!0   -- {"getId":10,"getTitle":"ガントチャート - 季節情報スマートフォン対応 - Redmine","getUrl":"https://redmine.transnet.ne.jp/projects/jrs-kisetsu-sp/issues/gantt?utf8=%E…
--     putStrLn $ show $ getTitle $ hoge!!0 -- "ガントチャート - 季節情報スマートフォン対応 - Redmine"
--     putStrLn $ toLowerCase $ show $ hoge!!0 -- {"getid":10,"gettitle":"ガントチャート - 季節情報スマートフォン対応 - redmine","geturl":"https://redmine.transnet.ne.jp/projects/jrs-kisetsu-sp/issues/gantt?utf8=%e…
--     putStrLn $ toLowerCase $ show $ getTitle $ hoge!!0 -- "ガントチャート - 季節情報スマートフォン対応 - redmine"
--     putStrLn $ show  $ "min" `isInfixOf` (toLowerCase $ show $ getTitle $ hoge!!0) -- true
    -----------------
    -----------------

    return ()

  isFocus <- isFocusingForm
  if isFocus
    then do
      writeRef modeRef FormFocusMode
      return ()
    else return ()

decideSelector :: Ref Mode -> Ref (Maybe Int) -> Ref [Item] -> Event -> Fay ()
decideSelector modeRef firstKeyCodeRef listRef e = do
  putStrLn "decideSelector"
  preventDefault e
  (id, typ, url, query) <- idTypeUrlQuery
--   putStrLn $ typ ++ ":" ++ id ++ ":" ++ url ++ ":" ++ query
  cancel modeRef firstKeyCodeRef e
  let jsonStr' = jsonStr id typ url query
--   putStrLn "jsonStr'"
--   putStrLn jsonStr'
--   chromeExtensionSendMessage (jsonStr id typ url query) $ \list -> do
  chromeExtensionSendMessage jsonStr' $ \list -> do
    putStrLn "decideSelector callback"
    items <- toItemsfromJSON $ show list
--     items <- fromJSON $ show list
    writeRef listRef items
    makeSelectorConsole items
    return ()

  select "#selectorInput" >>= jqVal
  return ()
  where
    idTypeUrlQuery :: Fay (String, String, String, String)
    idTypeUrlQuery = do
      j <- select "#selectorList tr.selected"
      url <- select "#selectorList tr.selected span.url" >>= jqText
      query <- select "#selectorInput" >>= jqVal
      id' <- arrToStr $ attr "itemid" j
      typ' <- arrToStr $ attr "itemtype" j
      url' <- arrToStr url
      query' <- arrToStr query
      return $ (id', typ', url', query')

    jsonStr :: String -> String -> String -> String -> String
    jsonStr id typ url query = "{\"mes\": \"decideSelector\", \"item\":{\"id\":\"" ++ id ++ "\", \"url\":" ++ url ++ ", \"type\":\"" ++ typ ++ "\", \"query\":\"" ++ query ++ "\"}}"

-- fromJSON :: String -> Fay [Item]
fromJSON :: String -> Fay [a]
fromJSON = ffi "JSON.parse(%1)"

toItemsfromJSON :: String -> Fay [Item]
toItemsfromJSON = ffi "JSON.parse(%1)"
