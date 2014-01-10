{-# OPTIONS_GHC -Wall #-}
{-# LANGUAGE Arrows, NoMonomorphismRestriction #-}

module Stock (
  insertCompany
 ,connect
 ,disconnect
 ,commit
 ,getDaily
) where

import qualified Database.HDBC as H
import Database.HDBC (disconnect, commit)
import qualified Database.HDBC.Sqlite3 as H
import Database.HDBC.Types (IConnection)
import Data.Time.Calendar
import Text.XML.HXT.Core
import Text.XML.HXT.Curl
import Control.Arrow

connect = H.connectSqlite3

data Company = Company {code :: Int, name :: String, mPrice :: Maybe Double} deriving (Show, Eq)
data Daily = Daily {
  companyCode :: Int
 ,adjustedPrice :: Double
 ,startPrice :: Double
 ,finishPrice :: Double
 ,highPrice :: Double
 ,lowPrice :: Double
 ,volume :: Integer
 ,date :: Day
} deriving (Show, Eq)

insertCompany :: IConnection conn => conn -> Stock.Company -> IO Integer
insertCompany conn (Company code name Nothing) = H.run conn "insert into company (code, name) values (?,?);" [H.toSql code, H.toSql name]
insertCompany conn (Company code name (Just price)) = H.run conn "insert into company (code, name, price) values (?,?,?);" [H.toSql code, H.toSql name, H.toSql price]

insertDaily :: IConnection conn => conn -> Stock.Daily -> IO Integer
insertDaily conn (Daily companyCode adjustedPrice startPrice finishPrice highPrice lowPrice volume date)
  = H.run conn "insert into daily (companyCode, adjustedPrice, startPrice, finishPrice, highPrice, lowPrice, volume, date) values (?,?,?,?,?,?,?,?)"
               [H.toSql companyCode,H.toSql adjustedPrice,H.toSql startPrice,H.toSql finishPrice,H.toSql highPrice,H.toSql lowPrice,H.toSql volume,H.toSql date]

hoge :: IO ()
hoge = do
  conn <- H.connectSqlite3 "test1.db"
  -- H.run conn "insert into company (code, name) values (?,?);" [H.toSql (3::Int), H.toSql "xxhoge"]
  insertCompany conn (Company 122 "あああ" (Just 235.5))
  insertDaily conn (Daily 122 200.0 291.0 200.0 299.1 190.9 2000008 (fromGregorian 2014 1 9))
  cs <- H.quickQuery' conn "select * from company;" []
  cs <- H.quickQuery' conn "select * from daily;" []
  print cs
  H.commit conn
  H.disconnect conn


-- getGuest = deep (isElem >>> hasName "guest") >>> 
--   proc x -> do
--     fname <- getText <<< getChildren <<< deep (hasName "fname") -< x
--     lname <- getText <<< getChildren <<< deep (hasName "lname") -< x
--     returnA -< Guest { firstName = fname, lastName = lname }

fuga = deep (isElem >>> hasName "guest") >>> 
  proc x -> do
    fname <- getText <<< getChildren <<< deep (hasName "fname") -< x
    lname <- getText <<< getChildren <<< deep (hasName "lname") -< x
    returnA -< (fname, lname)

getDaily = deep (isElem >>> hasName "daily") >>>
  proc d -> do
    date_   <- getText <<< getChildren <<< deep (hasName "date") -< d
    stPrice <- getText <<< getChildren <<< deep (hasName "opening_price") <<< deep (hasName "values") -< d
    hiPrice <- getText <<< getChildren <<< deep (hasName "high_price") <<<  deep (hasName "values") -< d
    loPrice <- getText <<< getChildren <<< deep (hasName "low_price") <<<  deep (hasName "values") -< d
    fiPrice <- getText <<< getChildren <<< deep (hasName "closing_price") <<<  deep (hasName "values") -< d
    returnA -< (date_, stPrice, hiPrice, loPrice, fiPrice)
