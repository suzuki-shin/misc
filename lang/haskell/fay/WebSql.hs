{-# LANGUAGE NoImplicitPrelude #-}

module WebSql where

import Language.Fay.FFI
import Language.Fay.Prelude

main :: Fay ()
main = do
  print "start[2012-11-16 14:01]"
  db <- openDB "faytest" "" "FAYTEST" 1048576
  print $ show db
  transaction db $ \tx -> do
    print "transaction"
    executeCreateTableSql tx
                          (\tx res -> return ())
                          (errCallBack "create err")
    print "create"
    executeInsertSql tx
                     (\tx res -> return ())
                     (errCallBack "insert err")
    print "insert"
    executeSelectSql tx
                     (\tx res -> print "select success")
                     (errCallBack "select err")
    print "select"
--   transaction db executeInsertSql
--   transaction db
--               (\tx -> ((\sql tx -> ffi "%1.executeSql(%2)") "CREATE TABLE IF NOT EXISTS items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, attr TEXT, is_saved INT DEFAULT 0 NOT NULL, ordernum INT DEFAULT 0, is_active INTEGER DEFAULT ?)"))
  alert "ALERT!!"

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
data Res
instance Show (Res)
instance Foreign (Res)

openDB :: String -> String -> String -> Int -> Fay Db
openDB = ffi "window.openDatabase(%1, %2, %3, %4)"

transaction :: Db -> (Tx -> Fay ()) -> Fay ()
transaction = ffi "%1.transaction(%2)"

executeCreateTableSql :: Tx -> (Tx -> Res -> Fay ()) -> (Tx -> Res -> Fay ()) -> Fay ()
executeCreateTableSql = ffi "%1.executeSql('CREATE TABLE IF NOT EXISTS test3 (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT)', [], %2, %3)"

executeInsertSql :: Tx -> (Tx -> Res -> Fay ()) -> (Tx -> Res -> Fay ()) -> Fay ()
-- executeInsertSql = ffi $ "%1.executeSql(\"" ++ "INSERT INTO test3 (name) values ('susu')" ++ "\", [], %2, %3)"
executeInsertSql = ffi "%1.executeSql(\"INSERT INTO test3 (name) values ('susu')\", [], %2, %3)"

executeSelectSql :: Tx -> (Tx -> Res -> Fay ()) -> (Tx -> Res -> Fay ()) -> Fay ()
executeSelectSql = ffi "%1.executeSql(\"select * from test3\", [], %2, %3)"

errCallBack :: String -> Tx -> Res -> Fay ()
errCallBack mes _ _ = print mes
