module Stock (
) where

import Data.Time.Calendar

data Uptype = DownDown | UpDown | DownUp | UpUp deriving (Show, Eq)

data DailyBuy = DailyBuy {
    date :: Day
  , mLastdayEnd :: Maybe Int
  , start :: Int
  , end :: Int
  , high :: Int
  , low :: Int
  , quantity :: Int
  , mUpType :: Maybe Uptype
} deriving (Show, Eq)

toDailyBuy :: Day -> Maybe Int -> Int -> Int -> Int -> Int -> Int -> DailyBuy
toDailyBuy date mL st en hi lo qu =
  DailyBuy date mL st en hi lo qu (mType mL st en)
    where
      mType :: Maybe Int -> Int -> Int -> Maybe Uptype
      mType Nothing _ _ = Nothing
      mType (Just la) st' en'
        | la >  st' && st' >  en' = Just DownDown
        | la <= st' && st' >  en' = Just UpDown
        | la >  st' && st' <= en' = Just DownUp
        | la <= st' && st' <= en' = Just UpUp

-- mBuySpread :: DailyBuy -> Maybe Int
-- mBuySpread (DailyBuy _ _ _ _ _ _ _ Nothing) = Nothing
-- mBuySpread (DailyBuy _ (Just la) st en hi lo qu (Just DownDown)) = Just $ hi - st + en - lo
-- mBuySpread (DailyBuy _ (Just la) st en hi lo qu (Just UpDown))   = Just $ hi - la + en - lo
-- mBuySpread (DailyBuy _ (Just la) st en hi lo qu (Just DownUp))   = Just $ hi - lo
-- mBuySpread (DailyBuy _ (Just la) st en hi lo qu (Just UpUp))     = Just $ st - la + hi - lo

-- mSellSpread :: DailyBuy -> Maybe Int
-- mSellSpread (DailyBuy _ _ _ _ _ _ _ Nothing) = Nothing
-- mSellSpread (DailyBuy _ (Just la) st en hi lo qu (Just DownDown)) = Just $ la - st + hi - lo
-- mSellSpread (DailyBuy _ (Just la) st en hi lo qu (Just UpDown))   = Just $ hi - lo
-- mSellSpread (DailyBuy _ (Just la) st en hi lo qu (Just DownUp))   = Just $ la - lo
-- mSellSpread (DailyBuy _ (Just la) st en hi lo qu (Just UpUp))     = Just $ st - lo + hi - en

-- Maybe (BuySpread, SellSpread)
mSpread :: DailyBuy -> Maybe (Int, Int)
mSpread (DailyBuy _ _ _ _ _ _ _ Nothing) = Nothing
mSpread (DailyBuy _ (Just la) st en hi lo qu (Just DownDown)) = Just (hi - st + en - lo, la - st + hi - lo)
mSpread (DailyBuy _ (Just la) st en hi lo qu (Just UpDown))   = Just (hi - la + en - lo, hi - lo)
mSpread (DailyBuy _ (Just la) st en hi lo qu (Just DownUp))   = Just (hi - lo, la - lo)
mSpread (DailyBuy _ (Just la) st en hi lo qu (Just UpUp))     = Just (st - la + hi - lo, st - lo + hi - en)

mNum :: DailyBuy -> Maybe (Int, Int)
mNum db = case (mSpread db) of
  Nothing -> Nothing
  -- Just (buySp, sellSp) -> Just buySp
  Just (buySp, sellSp) -> Just ((buyNum buySp sellSp (quantity db)), (sellNum buySp sellSp (quantity db)))
  where
    -- buyNum :: Int -> Int -> Int -> Float
    -- buyNum bsp ssp qua = qua * bsp / (bsp+ssp)
    -- sellNum :: Int -> Int -> Int -> Int
    -- sellNum bsp ssp qua = qua * ssp / (bsp+ssp)

