{-# OPTIONS_GHC -Wall #-}

import Control.Applicative ((<$>))
import Data.List.Split (splitOn)
import Data.Maybe (catMaybes)
-- import Data.List (tails)
-- import Data.Time.Calendar
import Stock

-- data DailyBuy' = DailyBuy' {dailyBuy :: DailyBuy, buyNum :: Float, sellNum :: Float, spr20 :: Maybe Float} deriving (Show, Eq)

main :: IO ()
main = do
  -- d <- (map toDailyBuy . conv) <$> readFile "data.tsv"
  d <- (map toDailyBuy . conv) <$> getContents
  putStrLn header
  mapM_ (putStrLn . (\(d,s,e,h,l,q,sp) -> show d ++ "\t" ++ show s ++ "\t" ++ show e ++ "\t" ++ show h ++ "\t" ++ show l ++ "\t"++  show q ++ "\t" ++ show sp)) $ zipWith (\a b -> (date a, start a, end a, high a, low a, quantity a, snd b)) d (spr 20 d)

toDailyBuy :: [String] -> DailyBuy
toDailyBuy ss = DailyBuy (readDay (ss!!0)) (read (ss!!1)) (read (ss!!2)) (read (ss!!3)) (read (ss!!4)) (read (ss!!5))

-- 入力文字列を日ごとのデータのリストに変換する(カンマを削除して、タブで分割する)
conv :: String -> [[String]]
conv = tail . map (splitOn "\t") . lines . filter (/=',')

header :: String
header = "日付\t始値\t終値\t高値\t安値\t出来高\tSPR20"
