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

data User = User {getId :: Int, getName :: Text, getMail :: Text} deriving Show
instance A.FromJSON User where
   parseJSON (A.Object v) = User <$> v .: "id" <*> v .: "name" <*> v .: "mail"
   parseJSON _            = mzero
instance A.ToJSON User where
   toJSON (User id name mail) = A.object ["id" .= id, "name" .= name, "mail" .= mail]


withRescue :: ActionM () -> ActionM ()
-- TODO Return proper status code
withRescue = flip rescue text

tFetchAllRows :: Statement -> IO [[Maybe Text]]
tFetchAllRows sth = do
  res <- fetchAllRows sth
  return $ map (map fromSql) res

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
  disconnect conn
  return res

insertUser :: User -> IO Integer
insertUser (User _ name mail) = insertDB "insert into users (name, email) values (?, ?)" [toSql name, toSql mail]

main = do
    scotty 3000 $ do
    -- Add any WAI middleware, they are run top-down.
    middleware logStdoutDev
--     middleware $ staticPolicy $ addBase "static"

    get "/" $ html "<html><head></head><body><form action=\"/user\" method=\"post\"><input type=\"hidden\" name=\"user\" value=\"{'name':'xxx','mail':'yyy@zzz.com'}\"><input type=\"submit\" value=\"submit\"></form></body></html>"

    get "/user/:id" $ withRescue $ do
      id <- param "id"
      res <- liftIO $ selectFetchDB "select id ,desc from test where id = ? order by id, desc" [toSql (id::String)]
      json $ listToMaybe res

    get "/users" $ withRescue $ do
      res <- liftIO $ selectFetchDB "select id ,desc from test order by id, desc" []
      json res

--     post "/user" $ withRescue $ do
    post "/user" $ withRescue $ do
      userData <- jsonData :: ActionM User
      res <- liftIO $ insertUser userData
      return ()

--       json userData
--       res <- liftIO $ insertDB "insert into users (name, mail) values (?, ?)" [name, mail]

--     get "/" $
--         mustache "views/home.mustache" $ Info "Haskell" 100

--     get "/spots" $ withRescue $ do
--         spots <- runDB $ map P.entityVal <$> P.selectList ([] :: [P.Filter Spot]) []
--         json spots

--     post "/spots" $ withRescue $ do
--         spotData <- jsonData :: ActionM Spot
--         spotId <- runDB $ P.insert spotData
--         spot <- runDB $ P.get spotId
--         json spot
