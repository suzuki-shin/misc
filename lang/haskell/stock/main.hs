{-# OPTIONS_GHC -Wall #-}

import Control.Applicative ((<$>))
import Data.List.Split (splitOn)
import Stock

main :: IO ()
main = do
  -- d <- (map toDailyBuy . conv) <$> readFile "data.tsv"
  d <- (map toDailyBuy . conv) <$> getContents
  putStrLn header'
  mapM_ putStrLn $ toTable d

toDailyBuy :: [String] -> DailyBuy
toDailyBuy ss = DailyBuy (readDay (ss!!0)) (read (ss!!1)) (read (ss!!2)) (read (ss!!3)) (read (ss!!4)) (read (ss!!5))

-- 入力文字列を日ごとのデータのリストに変換する(カンマを削除して、タブで分割する)
conv :: String -> [[String]]
conv = tail . map (splitOn "\t") . lines . filter (/=',')

header :: String
header = "日付\t始値\t終値\t高値\t安値\t出来高\tSPR20"
header' = "日付\t始値\t終値\t高値\t安値\t出来高\t買い枚数\t売り枚数\tSPR20"

toRow :: (Day, Float, Float, Float, Float, Float, Float) -> String
toRow (d,s,e,h,l,q,sp) = show d ++ "\t" ++ show s ++ "\t" ++ show e ++ "\t" ++ show h ++ "\t" ++ show l ++ "\t"++  show q ++ "\t" ++ show sp

toRow' (d,s,e,h,l,q,bn,sn,up,sp) = show d ++ "\t" ++ show s ++ "\t" ++ show e ++ "\t" ++ show h ++ "\t" ++ show l ++ "\t"++  show q ++ "\t" ++ show bn ++ "\t" ++ show sn ++ "\t" ++ show up ++ "\t" ++ show sp

toTable :: [DailyBuy] -> [String]
-- toTable dbs = map toRow $ reverse $ mergeSPR 20 dbs
toTable dbs = map toRow' $ reverse $ mergeSPR' 20 dbs
  where
    mergeSPR' days d = zipWith (\a (_,bn,sn,up,sp) -> (date a, start a, end a, high a, low a, quantity a, bn, sn, up, sp)) d (spr_ days d)
    mergeSPR days d = zipWith (\a b -> (date a, start a, end a, high a, low a, quantity a, snd b)) d (spr days d)

