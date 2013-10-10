module Stock (
    readDay
  , toDailyBuy
  , mNum
  , mSPR
  , DailyBuy (date, mLastdayEnd, start, end, high, low, quantity, mUpType)
) where

import Data.List.Split
import Data.Time.Calendar

data Uptype = DownDown | UpDown | DownUp | UpUp deriving (Show, Eq)

data DailyBuy = DailyBuy {
    date :: Day
  , mLastdayEnd :: Maybe Float
  , start :: Float
  , end :: Float
  , high :: Float
  , low :: Float
  , quantity :: Float
  , mUpType :: Maybe Uptype
} deriving (Show, Eq)

toDailyBuy :: Day -> Maybe Float -> Float -> Float -> Float -> Float -> Float -> DailyBuy
toDailyBuy date mL st en hi lo qu =
  DailyBuy date mL st en hi lo qu (mType mL st en)
    where
      mType :: Maybe Float -> Float -> Float -> Maybe Uptype
      mType Nothing _ _ = Nothing
      mType (Just la) st' en'
        | la >  st' && st' >  en' = Just DownDown
        | la <= st' && st' >  en' = Just UpDown
        | la >  st' && st' <= en' = Just DownUp
        | la <= st' && st' <= en' = Just UpUp

-- (買値幅, 売値幅)
mSpread :: DailyBuy -> Maybe (Float, Float)
mSpread (DailyBuy _ _ _ _ _ _ _ Nothing) = Nothing
mSpread (DailyBuy _ (Just la) st en hi lo qu (Just DownDown)) = Just (hi - st + en - lo, la - st + hi - lo)
mSpread (DailyBuy _ (Just la) st en hi lo qu (Just UpDown))   = Just (hi - la + en - lo, hi - lo)
mSpread (DailyBuy _ (Just la) st en hi lo qu (Just DownUp))   = Just (hi - lo, la - lo)
mSpread (DailyBuy _ (Just la) st en hi lo qu (Just UpUp))     = Just (st - la + hi - lo, st - lo + hi - en)

-- (買い枚数, 売り枚数)
mNum :: DailyBuy -> Maybe (Float, Float)
mNum db = case (mSpread db) of
  Nothing -> Nothing
  Just (buySp, sellSp) -> Just ((buyNum buySp sellSp (quantity db)), (sellNum buySp sellSp (quantity db)))
  where
    buyNum :: Float -> Float -> Float -> Float
    buyNum bsp ssp qua = qua * bsp / (bsp+ssp)
    sellNum :: Float -> Float -> Float -> Float
    sellNum bsp ssp qua = qua * ssp / (bsp+ssp)

-- 売り圧力レシオ
mSPR :: DailyBuy -> Maybe Float
mSPR db = case mNum db of
  Nothing -> Nothing
  Just (buyN, sellN) -> Just $ sellN / buyN

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
