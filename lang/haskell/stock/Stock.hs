module Stock (
    readDay
  , upType
  , spr
  , DailyBuy (DailyBuy, date, start, high, low, end, quantity)
  , Day
) where

import Data.List.Split (splitOn)
import Data.List (tails)
import Data.Time.Calendar (Day, fromGregorian)

data Uptype = DownDown          -- 前日終値より始値が下がり、始値より終値が下がる
            | UpDown            -- 前日終値より始値が上がり、始値より終値が下がる
            | DownUp            -- 前日終値より始値が下がり、始値より終値が上がる
            | UpUp              -- 前日終値より始値が上がり、始値より終値が上がり
            deriving (Show, Eq)

data DailyBuy = DailyBuy {
    date :: Day
  , start :: Float
  , high :: Float
  , low :: Float
  , end :: Float
  , quantity :: Float
} deriving (Show, Eq)


readDay :: String -> Day
readDay day = fromGregorian yyyy mm dd
  where
    day' = splitOn "-" day
    yyyy :: Integer
    yyyy = read $ day'!!0
    mm :: Int
    mm = read $ day'!!1
    dd :: Int
    dd = read $ day'!!2

upType :: Float -> DailyBuy -> Uptype
upType la (DailyBuy _ st _ _ en _)
  | la >  st && st >  en = DownDown
  | la <= st && st >  en = UpDown
  | la >  st && st <= en = DownUp
  | la <= st && st <= en = UpUp

-- | 買値幅
buySpread :: Float -> DailyBuy -> Float
buySpread la db@(DailyBuy _ st hi lo en _) = case upType la db of
  DownDown -> hi-st+en-lo
  UpDown   -> hi-la+en-lo
  DownUp   -> hi-lo
  UpUp     -> st-la+hi-lo

-- | 売値幅
sellSpread :: Float -> DailyBuy -> Float
sellSpread la db@(DailyBuy _ st hi lo en _) = case upType la db of
  DownDown -> la-st+hi-lo
  UpDown   -> hi-lo
  DownUp   -> la-lo
  UpUp     -> st-lo+hi-en

-- | 買い枚数
buyNum :: Float -> Float -> Float -> Float
buyNum buySpread sellSpread quantity = quantity * buySpread / (buySpread+sellSpread)

-- | 売り枚数
sellNum :: Float -> Float -> Float -> Float
sellNum buySpread sellSpread quantity = quantity * sellSpread / (buySpread+sellSpread)

-- | 売り圧力レシオ
spr :: Int -> [DailyBuy] -> [(Day, Float)]
spr days dbs = [(date (dbs_!!0), sellNumSum dbs_ / buyNumSum dbs_) | dbs_ <- tails dbs, length dbs_ >= days]
  where
    buyNumSum dbs'  = sum [
      buyNum (buySpread (end yesterday) today) (sellSpread (end yesterday) today) (quantity today)
      | today <- dbs', yesterday <- (tail (take days dbs'))]
    sellNumSum dbs' = sum [
      sellNum (sellSpread (end yesterday) today) (sellSpread (end yesterday) today) (quantity today)
      | today <- dbs', yesterday <- (tail (take days dbs'))]
