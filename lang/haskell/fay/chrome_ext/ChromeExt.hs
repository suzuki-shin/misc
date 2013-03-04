{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module ChromeExt where

import Prelude
import FFI

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
