{-# OPTIONS_GHC -Wall #-}
import Stock

main :: IO ()
main = do
  print "hoge"
  -- conn <- connect "test1.db"
  
  -- cs <- quickQuery' conn "select * from company;" []
  -- print cs
  -- disconnect conn
