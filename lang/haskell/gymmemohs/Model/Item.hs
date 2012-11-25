{-# LANGUAGE FlexibleInstances, TypeFamilies #-}
{-# LANGUAGE GADTs, FlexibleContexts, EmptyDataDecls #-}
{-# LANGUAGE OverloadedStrings #-}

module Item where

import Model.Base
import Model.User

data Item = ITem {getName :: String, getUnitName :: String, getUser :: User} deriving Show
instance A.FromJSON Item where
   parseJSON (A.Object v) = Item <$> v .: "name" <*> v .: "unitName" <*> .: "user"
   parseJSON _            = mzero
instance A.ToJSON Item where
   toJSON (Item name unitName user) = A.object ["name" .= name, "unitName" .= unitName, "user" .= user]

selectFetchDB :: String -> [SqlValue] -> IO [[Maybe Text]]
selectFetchDB sql params = do
  conn <- liftIO $ connectDB
  stmt <- liftIO $ prepare conn sql
  execute stmt params
  res <- tFetchAllRows stmt
  print res
  disconnect conn
  return res

insertDB :: String -> [SqlValue] -> IO Integer
insertDB sql params = do
  conn <- liftIO $ connectDB
  stmt <- liftIO $ prepare conn sql
  res <- execute stmt params
  commit conn
  disconnect conn
  return res

insertItem :: Item -> IO Integer
insertItem (Item name mail) = insertDB "insert into items (name, mail) values (?, ?)" [toSql name, toSql mail]
