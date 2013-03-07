{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module ChromeExt where

import Prelude
import FFI
import JS
import Hah.Types

data Message = Message { getMessageType :: String, getItem :: Item, getQuery :: String } deriving (Show)

-- chromeStorageSyncGet :: String -> (String -> Fay ()) -> Fay ()
-- chromeStorageSyncGet = ffi "chrome.storage.sync.get(%1, %2)"

-- chromeStorageSyncSet :: Fay ()
-- chromeStorageSyncSet = ffi "chrome.storage.sync.set({\"settings\":\"hogefugabz\"})"

-- chromeStorageSyncGet :: String -> (String -> Fay ()) -> Fay ()
-- chromeStorageSyncGet = ffi "chrome.storage.sync.get(%1, %2)"

-- chromeStorageSyncSet :: String -> Fay ()
-- chromeStorageSyncSet = ffi "chrome.storage.sync.set(JSON.parse(%1))"

chromeExtensionSendMessage :: String -> (a -> Fay ()) -> Fay ()
chromeExtensionSendMessage = ffi "chrome.extension.sendMessage(JSON.parse(%1), %2)"

chromeExtensionOnMessageAddListener :: (Message -> String -> ([a] -> Fay ()) -> Fay ()) -> Fay ()
chromeExtensionOnMessageAddListener = ffi "chrome.extension.onMessage.addListener(%1)"

chromeExtensionTabsQuery :: String -> ([a] -> Fay Deferred) -> Fay Deferred
chromeExtensionTabsQuery = ffi "chrome.tabs.query(JSON.parse(%1), %2)"

chromeExtensionHistorySearch :: String -> ([a] -> Fay Deferred) -> Fay Deferred
chromeExtensionHistorySearch = ffi "chrome.history.search(JSON.parse(%1), %2)"

chromeExtensionBookmarksSearch :: String -> ([a] -> Fay Deferred) -> Fay Deferred
chromeExtensionBookmarksSearch = ffi "chrome.bookmarks.search(%1, %2)"

chromeTabsUpdate :: String -> String -> Fay ()
chromeTabsUpdate = ffi "chrome.tabs.update(%1, %2)"

chromeTabsCreate :: String -> Fay ()
chromeTabsCreate = ffi "chrome.tabs.create(%1)"
