{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Control.Applicative
import           Snap.Core
import           Snap.Util.FileServe
import           Snap.Http.Server
import Control.Monad.IO.Class
import Database.HDBC
import Database.HDBC.Sqlite3

dbname :: FilePath
dbname = "gymmemo.db"

main :: IO ()
main = quickHttpServe site

site :: Snap ()
site =
    ifTop (writeBS "hello world") <|>
    route [ ("foo", writeBS "bar")
          , ("echo/:echoparam", echoHandler)
          , ("user/:name/:age", userHandler)
          ] <|>
    dir "static" (serveDirectory ".")

echoHandler :: Snap ()
echoHandler = do
    param <- getParam "echoparam"
    writeBS $ case param of
      Nothing -> "error"
      Just p ->  p

userHandler :: Snap ()
userHandler = do
    param <- getParams
    liftIO $ print param
    writeBS "param"

storeHandler :: Snap ()
storeHandler = do
  param <- getParam "storeparam"
  case param of
    Nothing -> writeBS "param error"
--     Just p -> liftIO $ BS.appendFile "db.txt" p
    Just p -> liftIO $ do
      conn <- connectSqlite3 "test1.db"
--       run conn "create table test (id integer not null, desc varchar(80)) if not exists" []
      run conn "insert into test (id, desc) values (1, ?)" [SqlByteString p]
      commit conn
      disconnect conn
      return ()

addUserHandler :: Snap ()
addUserHandler = do
  param <- getParam "user"
  case param of
    Nothing -> writeBS "param error"
--     Just p -> liftIO $ BS.appendFile "db.txt" p
    Just p -> liftIO $ do
      conn <- connectSqlite3 dbname
      run conn "INSERT INTO User (name) values (?)" [SqlByteString p]
      commit conn
      disconnect conn
      return ()

addItemHandler :: Snap ()
addItemHandler = do
  param <- getParam "user"
  case param of
    Nothing -> writeBS "param error"
--     Just p -> liftIO $ BS.appendFile "db.txt" p
    Just p -> liftIO $ do
      conn <- connectSqlite3 dbname
      run conn "INSERT INTO User (name) values (?)" [SqlByteString p]
      commit conn
      disconnect conn
      return ()

