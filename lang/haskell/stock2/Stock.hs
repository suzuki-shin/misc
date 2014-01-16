{-# OPTIONS_GHC -Wall #-}
{-# LANGUAGE Arrows, NoMonomorphismRestriction #-}

module Stock (
  insertCompany
 ,insertDaily
 ,selectDaily
 ,connect
 ,disconnect
 ,commit
 -- ,getDaily
 ,getDailyYF
 ,getDailyYFByUrl
 ,xxx
) where

import qualified Database.HDBC as H
import Database.HDBC (disconnect, commit)
import qualified Database.HDBC.Sqlite3 as H
import Database.HDBC.Types (IConnection)
import Data.Time.Calendar
import Text.XML.HXT.Core
import Text.XML.HXT.Curl
import Text.HandsomeSoup
import qualified Text.XML.HXT.DOM.XmlNode as XN
import Control.Arrow
import Control.Applicative ((<$>))
import Control.Monad (forM_)
import Data.List
import Data.Maybe
import Data.Char
import Data.Time
import Data.List.Split (splitOn)
-- import Data.ByteString (ByteString)

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
 -- ,date :: String
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
  -- r <- getDaily_ $ (show . head) codes
  -- print r
  print codes
  H.commit conn
  H.disconnect conn

atTag tag = deep (isElem >>> hasName tag)
text = getChildren >>> getText

-- getDaily = atTag "daily" >>>
--   proc d -> do
--     date_   <- text <<< atTag "date" -< d
--     vs <- atTag "values" -< d
--     stPrice <- text <<< atTag "opening_price" -< vs
--     hiPrice <- text <<< atTag "high_price"    -< vs
--     loPrice <- text <<< atTag "low_price"     -< vs
--     fiPrice <- text <<< atTag "closing_price" -< vs
--     volume  <- text <<< atTag "turnover" -< vs
--     returnA -< (date_, stPrice, hiPrice, loPrice, fiPrice, volume)

-- getDaily_ code = runX (readDocument [withCurl []] url >>> getDaily)
--   where
--     url = "http://ikachi.sub.jp/kabuka/api/d/xml.php?stdate=20100104&eddate=20100107&code=" ++ code

getDailyYF code = getDailyYFByUrl code $ "http://info.finance.yahoo.co.jp/history/?code=" ++ (show code)
  -- let doc = fromUrl $ "http://info.finance.yahoo.co.jp/history/?code=" ++ (show code)
  -- r <- runX $ doc >>> css "td" //> getText
  -- return $ map (toDaily code) $ groupn 7 $ (drop 3) . (takeWhile (/="\n")) $ r

getDailyYFByUrl code url = do
  let doc = fromUrl url
  r <- runX $ doc >>> css "td" //> getText
  return $ catMaybes $ map (toDaily code) $ groupn 7 $ (drop 3) . (takeWhile (/="\n")) $ r

-- http://www.sampou.org/cgi-bin/haskell.cgi?Programming%3a%E7%8E%89%E6%89%8B%E7%AE%B1%3a%E3%83%AA%E3%82%B9%E3%83%88#H-3w0gini39h96e
-- groupn n = unfoldr phi
--     where phi [] = Nothing
--           phi xs = Just $ splitAt n xs

-- http://d.hatena.ne.jp/ha-tan/20061021/1161442240
groupn :: Int -> [a] -> [[a]]
groupn _ [] = []
groupn n xs =
  let (xs1, xs2) = splitAt n xs
  in xs1 : groupn n xs2

toDaily :: Int -> [String] -> Maybe Daily
toDaily code params
  | length params == 7 = Just $ Daily code adj st fi hi lo vol dt
  | otherwise          = Nothing
  where
    fromNenGappi :: String -> String
    fromNenGappi = (map _fromNenGetsu) . _delHi
    _fromNenGetsu '年' = '-'
    _fromNenGetsu '月' = '-'
    _fromNenGetsu c = c
    _delHi = filter (/='日')
    dt = strToDay $ fromNenGappi (params!!0)
    delComma = filter (/=',')
    adj = (read . delComma) (params!!6)
    st  = (read . delComma) (params!!1)
    hi  = (read . delComma) (params!!3)
    lo  = (read . delComma) (params!!4)
    fi  = (read . delComma) (params!!2)
    vol = (read . delComma) (params!!5)

selectDaily conn = H.quickQuery' conn "select date, startPrice, finishPrice, highPrice, lowPrice, volume, adjustedPrice  from daily order by julianday(date) desc;" []

xxx conn = do
  codes <- selectDaily conn
  let vs :: [(String, [String])]
      vs = map (\c -> ((H.fromSql . head) c , ((map H.fromSql) . tail) c)) codes
      vs' = map ((toDaily 3668) . (\v -> fst v:snd v)) vs
      vs'' = catMaybes vs'
  return vs''
  -- return $ map (catMaybes . (toDaily 3668) . (map (H.fromSql::H.SqlValue -> Int))) codes

strToDay :: String -> Day
strToDay s = fromGregorian yyyy mm dd
  where
    listToTuple3 :: [String] -> (Integer, Int, Int)
    listToTuple3 [x,y,z] = (read x, read y, read z)
    listToTuple3 _ = error "xxx"
    (yyyy, mm, dd) = listToTuple3 (splitOn "-" s)

