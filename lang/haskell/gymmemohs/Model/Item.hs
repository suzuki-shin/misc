{-# LANGUAGE FlexibleInstances, TypeFamilies #-}
{-# LANGUAGE GADTs, FlexibleContexts, EmptyDataDecls #-}
{-# LANGUAGE OverloadedStrings #-}

module Model.Item where

import Control.Monad
import Control.Monad.Trans
import Control.Applicative
import qualified Data.Aeson as A
import Data.Aeson ((.:),(.=))
import Database.HDBC

import Model.Base
import Model.User (User)

data Item = Item {getName :: String, getUnitName :: String, getUserId :: Int} deriving Show
instance A.FromJSON Item where
   parseJSON (A.Object v) = Item <$> v .: "name" <*> v .: "unitName" <*> v .: "user"
   parseJSON _            = mzero
instance A.ToJSON Item where
   toJSON (Item name unitName userId) = A.object ["name" .= name, "unitName" .= unitName, "userId" .= userId]

createTableItem = executeDB "create table if not exists items (id integer primary key autoincrement, name varchar(128) not null, unitName varchar(128) not null, userId integer not null)" []

insertItem :: Item -> IO Integer
insertItem (Item name unitName userId) = do
  createTableItem
  executeDB "insert into items (name, unitName, userId) values (?, ?, ?)" [toSql name, toSql unitName, toSql userId]
