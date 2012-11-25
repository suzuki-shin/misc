{-# LANGUAGE FlexibleInstances, TypeFamilies #-}
{-# LANGUAGE GADTs, FlexibleContexts, EmptyDataDecls #-}
{-# LANGUAGE OverloadedStrings #-}

module User where

import Model.Base

data User = User {getName :: String, getMail :: String} deriving Show
instance A.FromJSON User where
   parseJSON (A.Object v) = User <$> v .: "name" <*> v .: "mail"
   parseJSON _            = mzero
instance A.ToJSON User where
   toJSON (User name mail) = A.object ["name" .= name, "mail" .= mail]

selectFetchDB :: String -> [SqlValue] -> IO [[Maybe Text]]
selectFetchDB sql params = do
  conn <- liftIO $ connectSqlite3 "test1.db"
  stmt <- liftIO $ prepare conn sql
  execute stmt params
  res <- tFetchAllRows stmt
  print res
  disconnect conn
  return res

insertDB :: String -> [SqlValue] -> IO Integer
insertDB sql params = do
  conn <- liftIO $ connectSqlite3 "test1.db"
  stmt <- liftIO $ prepare conn sql
  res <- execute stmt params
  commit conn
  disconnect conn
  return res

insertUser :: User -> IO Integer
insertUser (User name mail) = insertDB "insert into users (name, mail) values (?, ?)" [toSql name, toSql mail]
