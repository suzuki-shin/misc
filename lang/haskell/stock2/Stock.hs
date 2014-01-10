{-# OPTIONS_GHC -Wall #-}
{-# LANGUAGE Arrows, NoMonomorphismRestriction #-}

module Stock (
  insertCompany
 ,connect
 ,disconnect
 ,commit
 ,getDaily
 ,hoge
) where

import qualified Database.HDBC as H
import Database.HDBC (disconnect, commit)
import qualified Database.HDBC.Sqlite3 as H
import Database.HDBC.Types (IConnection)
import Data.Time.Calendar
import Text.XML.HXT.Core
import Text.XML.HXT.Curl
import Control.Arrow
import Control.Applicative ((<$>))
import Control.Monad (forM_)

connect = H.connectSqlite3

data Company = Company {code :: Int, name :: String} deriving (Show, Eq)
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
insertCompany conn (Company code name) = H.run conn "insert into company (code, name) values (?,?);" [H.toSql code, H.toSql name]

insertDaily :: IConnection conn => conn -> Stock.Daily -> IO Integer
insertDaily conn (Daily companyCode adjustedPrice startPrice finishPrice highPrice lowPrice volume date)
  = H.run conn "insert into daily (companyCode, adjustedPrice, startPrice, finishPrice, highPrice, lowPrice, volume, date) values (?,?,?,?,?,?,?,?)"
               [H.toSql companyCode,H.toSql adjustedPrice,H.toSql startPrice,H.toSql finishPrice,H.toSql highPrice,H.toSql lowPrice,H.toSql volume,H.toSql date]

hoge :: IO ()
hoge = do
  conn <- H.connectSqlite3 "test1.db"
  -- H.run conn "insert into company (code, name) values (?,?);" [H.toSql (3::Int), H.toSql "xxhoge"]
  -- insertCompany conn (Company 122 "あああ" (Just 235.5))
  -- insertDaily conn (Daily 122 200.0 291.0 200.0 299.1 190.9 2000008 (fromGregorian 2014 1 9))
  codes <- map ((H.fromSql::H.SqlValue -> Int) . head) <$> H.quickQuery' conn "select code from company;" []
  -- cs <- H.quickQuery' conn "select * from daily;" []
  -- mapM_ print codes
  -- forM_ codes $ \code -> do
  -- mapM_ (\code -> do
  --   (_, st, hi, lo, fi, vol) <- getDaily_ (show code)
  --   print $ Daily code (read st) (read fi) (read hi) (read lo) (read vol) (fromGregorian 2014 1 10)
  --   ) codes
  r <- getDaily_ $ (show . head) codes
  print r
  print codes
  H.commit conn
  H.disconnect conn

atTag tag = deep (isElem >>> hasName tag)
text = getChildren >>> getText

getDaily = atTag "daily" >>>
  proc d -> do
    date_   <- text <<< atTag "date" -< d
    vs <- atTag "values" -< d
    stPrice <- text <<< atTag "opening_price" -< vs
    hiPrice <- text <<< atTag "high_price"    -< vs
    loPrice <- text <<< atTag "low_price"     -< vs
    fiPrice <- text <<< atTag "closing_price" -< vs
    volume  <- text <<< atTag "turnover" -< vs
    returnA -< (date_, stPrice, hiPrice, loPrice, fiPrice, volume)

getDaily_ code = runX (readDocument [withCurl []] url >>> getDaily)
  where
    url = "http://ikachi.sub.jp/kabuka/api/d/xml.php?stdate=20100104&eddate=20100107&code=" ++ code
