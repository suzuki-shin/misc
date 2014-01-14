{-# OPTIONS_GHC -Wall #-}
-- import Text.XML.HXT.Core
-- import Text.XML.HXT.Curl
-- import Control.Arrow
import Stock

url = "http://ikachi.sub.jp/kabuka/api/d/xml.php?code=3778&stdate=20100104&eddate=20100107"

main :: IO ()
main = do
  -- r <- getDailyYF 3668
  r <- getDailyYFByUrl 3668 "http://info.finance.yahoo.co.jp/history/?code=3668.T&sy=2013&sm=6&sd=1&ey=2013&em=7&ed=28&tm=d"
  mapM_ print r
  -- r <-  runX (readDocument [withCurl []] url >>> getDaily)
  -- mapM_ print r
  conn <- connect "test1.db"
  mapM_ (insertDaily conn) r
  commit conn
  disconnect conn

  -- cs <- quickQuery' conn "select * from company;" []
  -- print cs
  -- disconnect conn
