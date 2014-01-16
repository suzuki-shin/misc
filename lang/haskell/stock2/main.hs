{-# OPTIONS_GHC -Wall #-}
-- import Text.XML.HXT.Core
-- import Text.XML.HXT.Curl
import Control.Applicative
import Stock

main :: IO ()
main = do
  -- r <- getDailyYF 3668
  r <- getDailyYFByUrl 3668 "http://info.finance.yahoo.co.jp/history/?code=3668.T&sy=2013&sm=7&sd=1&ey=2013&em=9&ed=25&tm=d&p=2"
  -- mapM_ print r
  -- r <-  runX (readDocument [withCurl []] url >>> getDaily)
  -- mapM_ print r
  conn <- connect "test2.db"
  mapM_ (insertDaily conn) r
  -- codes <- selectDaily conn
  -- map ((map (H.fromSql::H.SqlValue -> Int)) . (toDaily 3668)) codes
  -- xxx conn
  commit conn
  disconnect conn

  -- cs <- quickQuery' conn "select * from company;" []
  -- print cs
  -- disconnect conn
