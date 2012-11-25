{-# LANGUAGE QuasiQuotes, TemplateHaskell, TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances, TypeFamilies #-}
{-# LANGUAGE GADTs, FlexibleContexts, EmptyDataDecls #-}
{-# LANGUAGE OverloadedStrings #-}
import Web.Scotty

import Network.Wai.Middleware.RequestLogger -- install wai-extra if you don't have this
import Control.Monad.Trans
import Control.Applicative
import Data.Monoid
import System.Random (newStdGen, randomRs)
import Network.HTTP.Types (status302)
import Network.Wai
import qualified Data.Text.Lazy as T

import Data.Text.Lazy.Encoding (decodeUtf8)
import Data.Text (Text)
import Database.HDBC
import Database.HDBC.Sqlite3
import qualified Data.Aeson as A
import Data.Aeson ((.:),(.=))
import Control.Monad
import Data.Maybe
import Model
import Model.User
import Model.Item

-- Model
-- data User = User {getName :: String, getMail :: String} deriving Show
-- instance A.FromJSON User where
--    parseJSON (A.Object v) = User <$> v .: "name" <*> v .: "mail"
--    parseJSON _            = mzero
-- instance A.ToJSON User where
--    toJSON (User name mail) = A.object ["name" .= name, "mail" .= mail]

-- data Item = Item {getUser :: User, getName' :: String, getUnitName :: String} deriving Show


withRescue :: ActionM () -> ActionM ()
-- TODO Return proper status code
withRescue = flip rescue text

-- tFetchAllRows :: Statement -> IO [[Maybe Text]]
-- tFetchAllRows sth = do
--   res <- fetchAllRows sth
--   return $ map (map fromSql) res

-- selectFetchDB :: String -> [SqlValue] -> IO [[Maybe Text]]
-- selectFetchDB sql params = do
--   conn <- liftIO $ connectSqlite3 "test1.db"
--   stmt <- liftIO $ prepare conn sql
--   execute stmt params
--   res <- tFetchAllRows stmt
--   print res
--   disconnect conn
--   return res

-- insertDB :: String -> [SqlValue] -> IO Integer
-- insertDB sql params = do
--   conn <- liftIO $ connectSqlite3 "test1.db"
--   stmt <- liftIO $ prepare conn sql
--   res <- execute stmt params
--   commit conn
--   disconnect conn
--   return res

-- insertUser :: User -> IO Integer
-- insertUser (User name mail) = insertDB "insert into users (name, mail) values (?, ?)" [toSql name, toSql mail]

main = do
    scotty 3000 $ do
    -- Add any WAI middleware, they are run top-down.
    middleware logStdoutDev
--     middleware $ staticPolicy $ addBase "static"

    get "/" $ html "<html><head></head><body><h1>test</h1><script type=\"text/javascript\" src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js\"></script><script type=\"text/javascript\">$.ajax({url:'http://localhost:3000/jsontest',type:'POST',dataType:'json',data:JSON.stringify({name:'aauuu',mail:'bbbbbb'}),success: function(){console.log('suc');},error: function(){console.log('err');}});</script></body></html>" --"<html><head></head><body><form action=\"/jsontest\" method=\"post\"><input type=\"hidden\" value=\"{'name':'xxx','mail':'yyy@zzz.com'}\"><input type=\"submit\" value=\"submit\"></form></body></html>"
    get "/testpost" $ html "<html><head></head><body><form action=\"/usertest\" method=\"post\"><input type=\"hidden\" name=\"name\" value=\"xxx1\"><input type=\"hidden\" name=\"mail\" value=\"yyy1@zzz.com\"><input type=\"submit\" value=\"submit\"></form></body></html>"

    get "/user/:mail" $ withRescue $ do
      mail <- param "mail"
      res <- liftIO $ selectFetchDB "select * from users where mail = ?" [toSql (mail::String)]
      json $ listToMaybe res

    get "/users" $ withRescue $ do
      res <- liftIO $ selectFetchDB "select * from users" []
      json res

    post "/usertest" $ withRescue $ do
      name <- param "name"
      mail <- param "mail"
      res <- liftIO $ insertUser (User name mail)
      json res

    post "/jsontest" $ withRescue $ do
      userData <- jsonData :: ActionM User
      res' <- liftIO $ insertUser userData
      res <- liftIO $ insertUser (User "KUSUKU" "HOGE@FUGA")
      json res
