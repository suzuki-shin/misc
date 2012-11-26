{-# LANGUAGE FlexibleInstances, TypeFamilies #-}
{-# LANGUAGE GADTs, FlexibleContexts, EmptyDataDecls #-}
{-# LANGUAGE OverloadedStrings #-}

module Model.Base (selectFetchDB, executeDB) where

-- import Network.Wai.Middleware.RequestLogger -- install wai-extra if you don't have this
import Control.Monad.Trans
-- import Data.Monoid
-- import System.Random (newStdGen, randomRs)
-- import Network.HTTP.Types (status302)
-- import Network.Wai
import qualified Data.Text.Lazy as T

import Data.Text.Lazy.Encoding (decodeUtf8)
import Data.Text (Text)
import Database.HDBC
import Database.HDBC.Sqlite3
import Control.Monad
import Data.Maybe
import Data.Convertible.Base

dbname :: String
dbname = "test1.db"

connectDB :: FilePath -> IO Connection
connectDB dbname = connectSqlite3 dbname

tFetchAllRows :: Statement -> IO [[Maybe Text]]
tFetchAllRows sth = do
  res <- fetchAllRows sth
  return $ map (map fromSql) res

selectFetchDB :: String -> [SqlValue] -> IO [[Maybe Text]]
selectFetchDB sql params = do
  conn <- liftIO $ connectDB dbname
  stmt <- liftIO $ prepare conn sql
  execute stmt params
  res <- tFetchAllRows stmt
  print res
  disconnect conn
  return res

executeDB sql params = do
  conn <- liftIO $ connectSqlite3 "test1.db"
  stmt <- liftIO $ prepare conn sql
  res <- execute stmt params
  commit conn
  disconnect conn
  return res
