{-# LANGUAGE FlexibleInstances, TypeFamilies #-}
{-# LANGUAGE GADTs, FlexibleContexts, EmptyDataDecls #-}
{-# LANGUAGE OverloadedStrings #-}

module Model.User where

import Control.Monad
import Control.Monad.Trans
import Control.Applicative
import qualified Data.Aeson as A
import Data.Aeson ((.:),(.=))
import Database.HDBC
import Model.Base

data User = User {getId :: Maybe Int, getName :: String, getMail :: String} deriving Show
instance A.FromJSON User where
   parseJSON (A.Object v) = User <$> v .: "id" <*> v .: "name" <*> v .: "mail"
   parseJSON _            = mzero
instance A.ToJSON User where
   toJSON (User id name mail) = A.object ["id" .= id, "name" .= name, "mail" .= mail]

createTableUser = executeDB "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name VARCHAR(128) NOT NULL, mail VARCHAR(128) NOT NULL)" []

insertUser :: User -> IO Integer
insertUser (User _ name mail) = do
  createTableUser
  executeDB "INSERT INTO users (name, mail) VALUES (?, ?)" [toSql name, toSql mail]
