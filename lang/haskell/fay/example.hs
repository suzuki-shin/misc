{-# LANGUAGE NoImplicitPrelude #-}

module Example where

import Language.Fay.FFI
import Language.Fay.Prelude

main :: Fay ()
-- main = print "FFFFAY"
-- main = alert "ALLLL"
main = do
  print "FFFFAAAY!"
  db <- openDB "fuga" "" "FUGA" 1048576
  print $ show db
--   transaction db (\tx -> (executeSql tx "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, attr TEXT, is_saved INT DEFAULT 0 NOT NULL, ordernum INT DEFAULT 0, is_active INTEGER DEFAULT ?)"))
  transaction db
              (\tx -> ((\sql tx -> ffi "%1.executeSql(%2)") "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, attr TEXT, is_saved INT DEFAULT 0 NOT NULL, ordernum INT DEFAULT 0, is_active INTEGER DEFAULT ?)"))
  alert "ALLERRT"

data Role = CEO
          | Manager
          | Developer
          | Marketing

alert :: String -> Fay ()
alert = ffi "window.alert(%1)"

print :: String -> Fay ()
print = ffi "console.log(%1)"

data Db
instance Show (Db)
instance Foreign (Db)
data Tx
instance Show (Tx)
instance Foreign (Tx)

openDB :: String -> String -> String -> Int -> Fay Db
openDB = ffi "window.openDatabase(%1, %2, %3, %4)"
-- openDB :: String -> String -> String -> Int -> Fay ()
-- openDB = ffi "window.openDatabase(%1, %2, %3, %4)"

transaction :: Db -> (Tx -> String -> Bool) -> Fay ()
transaction = ffi "%1.transaction(%2)"

-- createTable :: Tx -> String -> [a] -> Bool
-- createTable = ffi "%1.executeSql(%2, %3)"

-- executeSql :: Tx -> String -> Bool
-- executeSql = ffi "%1.executeSql(%2)"