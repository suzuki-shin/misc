{-# OPTIONS_GHC -Wall #-}

import Control.Applicative ((<$>))
import Data.List.Split (splitOn)
import Data.Maybe (catMaybes)
import Data.List (tails)
import Data.Time.Calendar
import Stock

data DailyBuy' = DailyBuy' {dailyBuy :: DailyBuy, buyNum :: Float, sellNum :: Float, sprPer20 :: Maybe Float} deriving (Show, Eq)

main :: IO ()
main = do
  d <- conv <$> readFile "data.tsv"
  let d' = zipWith toDailyBuy' d (tail d)
      buySells = tail $ catMaybes $ map mNum d'
      -- buyN = sum $ map fst buySells
      -- sellN = sum $ map snd buySells
      dbList = zipWith (\db (b, s) -> DailyBuy' db b s Nothing) d' buySells
  -- print $ head dates
  -- print $ last dates
  -- print sprt
  -- print buySells
  -- print dbList
  putStrLn header
  mapM_ (putStrLn . toRow) dbList
  -- print $ (spr . take 5) dbList
  mapM_ print $ zip (sprList 20 dbList) (sprList 5 dbList)

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

toRow :: DailyBuy' -> String
toRow db' = ((show . date . dailyBuy) db') ++ "\t" ++
            ((show . buyNum) db') ++ "\t" ++
            ((show . sellNum) db')

toTable :: [DailyBuy'] -> [String]
toTable dbs' = undefined

header :: String
header = "日付\t買い枚数\t売り枚数"

mSpr :: [DailyBuy'] -> Maybe (Day, Float)
mSpr [] = Nothing
mSpr dbs = Just (date (dailyBuy (head dbs)), (sellSum dbs) / (buySum dbs))
  where
    buySum :: [DailyBuy'] -> Float
    buySum = sum . (map buyNum)
    sellSum :: [DailyBuy'] -> Float
    sellSum = sum . (map sellNum)

sprList :: Int -> [DailyBuy'] -> [(Day, Float)]
sprList num = catMaybes . map (mSpr . (take num)) . filter ((>= num) . length) . tails
