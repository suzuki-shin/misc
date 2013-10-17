{-# OPTIONS_GHC -Wall #-}

import Control.Applicative ((<$>))
import Data.List.Split (splitOn)
import Data.Maybe (catMaybes)
import Data.List (tails)
-- import Data.Time.Calendar
import Stock

data DailyBuy' = DailyBuy' {dailyBuy :: DailyBuy, buyNum :: Float, sellNum :: Float, spr20 :: Maybe Float} deriving (Show, Eq)

main :: IO ()
main = do
  -- d <- conv <$> readFile "data.tsv"
  d <- conv <$> getContents
  let d' = zipWith toDailyBuy' d (tail d)
      buySells = tail $ catMaybes $ map mNum d'
      dbList = zipWith (\db (b, s) -> DailyBuy' db b s Nothing) d' buySells
  putStrLn header
  mapM_ (putStrLn . toRow) $ sprList 20 dbList

-- 入力文字列を日ごとのデータのリストに変換する(カンマを削除して、タブで分割する)
conv :: String -> [[String]]
conv = tail . map (splitOn "\t") . lines . filter (/=',')

toDailyBuy' :: [String] -> [String] -> DailyBuy
toDailyBuy' yesterday today = toDailyBuy (readDay (today!!0))
                                         (Just (read (yesterday!!3)))
                                         (read (today!!1))
                                         (read (today!!4))
                                         (read (today!!2))
                                         (read (today!!3))
                                         (read (today!!5))

toRow :: (DailyBuy', Maybe Float) -> String
toRow (db', mSpr20) = ((show . date . dailyBuy) db') ++ "\t" ++
                      ((show . start . dailyBuy) db') ++ "\t" ++
                      ((show . end . dailyBuy) db') ++ "\t" ++
                      ((show . high . dailyBuy) db') ++ "\t" ++
                      ((show . low . dailyBuy) db') ++ "\t" ++
                      ((show . quantity . dailyBuy) db') ++ "\t" ++
                      spr20'
  where
    spr20' = case mSpr20 of
      Just spr -> show spr
      Nothing  -> ""

toTable :: [DailyBuy'] -> [String]
toTable dbs' = undefined

header :: String
header = "日付\t始値\t終値\t高値\t安値\t出来高\tSPR20"

mSpr :: [DailyBuy'] -> Maybe Float
mSpr [] = Nothing
mSpr dbs = case buySum of
  0 -> Nothing
  _ -> Just $ sellSum/buySum
  where
    buySum :: Float
    buySum = sum . (map buyNum) $ dbs
    sellSum :: Float
    sellSum = sum . (map sellNum) $ dbs

sprList :: Int -> [DailyBuy'] -> [(DailyBuy', Maybe Float)]
sprList num dbs' = zip dbs' $ (map (mSpr . (take num)) . filter ((>= num) . length) . tails) dbs'
