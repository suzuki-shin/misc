{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module Background where

import Prelude
import FFI
import MyPrelude
import Hah.Types
import Hah.Configs
import JS
import ChromeExt

main :: Fay ()
main = do
--   ready $ do
    putStrLn "[2013-03-07 15:32]"
    chromeExtensionOnMessageAddListener $ \msg _ sendResponse -> do
      putStrLn "chromeExtensionOnMessageAddListener"
      return () --
--       putStrLn $ getMessageType msg
--       case getMessageType msg of
--         "makeSelectorConsole" -> makeSelectorConsole sendResponse
--         "decideSelector" -> decideSelector msg sendResponse
--         _ -> do
--           putStrLn "?"
--           return ()
    return ()

tabSelect :: Fay Deferred
tabSelect = do
  dfd <- deferred
  chromeExtensionTabsQuery opt (toItems "tab" dfd)
  promise dfd
  where
    opt = "{\"currentWindow\": true}"

historySelect :: Fay Deferred
historySelect = do
  dfd <- deferred
  chromeExtensionHistorySearch opt (toItems "history" dfd)
  promise dfd
  where
    opt = "{\"text\": \"\", \"maxResults\": 1000}"

bookmarkSelect :: Fay Deferred
bookmarkSelect = do
  dfd <- deferred
  chromeExtensionBookmarksSearch "h" (toItems "bookmark" dfd)
  promise dfd

selectList :: ([a] -> Fay ()) -> Fay ()
-- selectList f = jqWhen [tabSelect, historySelect, bookmarkSelect] >>= jqDone $ \[ts, hs, bs] -> f (ts ++ hs ++ bs)
selectList f = do
  dfd <- jqWhen [tabSelect, historySelect, bookmarkSelect]
  jqDone funcAtDone dfd
  return ()
  where
--     funcAtDone :: [a] -> Fay ()
    funcAtDone xs = f (concat xs) >> return ()

toItems :: String -> Deferred -> ([Item] -> Fay Deferred)
toItems typ dfd = (\xs -> resolve [Item (getId x) (getTitle x) (getUrl x) typ | x <- xs] dfd)

deferred :: Fay Deferred
deferred = ffi "$.Deferred()"

resolve :: [a] -> Deferred -> Fay Deferred
resolve = ffi "%2.resolve(%1)"

promise :: Deferred -> Fay Deferred
promise = ffi "%1.promise()"

jqWhen :: [Fay Deferred] -> Fay Deferred
jqWhen = ffi "$.when(%1)"

jqDone :: (a -> Fay ()) -> Deferred -> Fay Deferred
jqDone = ffi "%2.done(%1)"

makeSelectorConsole :: ([a] -> Fay ()) -> Fay ()
makeSelectorConsole f = do
  putStrLn "makeSelectorConsole"
  selectList f >> return ()

decideSelector :: Message -> ([a] -> Fay ()) -> Fay ()
decideSelector msg f = do
  putStrLn "decideSelector"
  let item = getItem msg
  case getType item of
    "tab" -> do
      putStrLn "tabs.update"
      chromeTabsUpdate (getId item) "{\"active\": true}"
    "websearch" -> do
      putStrLn "web search"
      chromeTabsCreate $ "{\"url\":" ++ getUrl item ++ "}"
--       chromeTabsCreate $ "{\"url\":" ++ getUrl item ++ getQuery msg ++ "}"
    _ -> chromeTabsCreate $ "{\"url\":" ++ getUrl item ++ "}"
  selectList f
  return ()
