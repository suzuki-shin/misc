{-# OPTIONS_GHC -Wall #-}

module MyDate where

import Data.List.Split (splitOn)
import Data.Time.Calendar (Day, fromGregorian)

-- | "2014-1-10"みたいな文字列をDay型データにして返す
-- >>> strToDay "2014-1-10"
-- 2013-01-10
strToDay :: String -> Day
strToDay s = fromGregorian yyyy mm dd
  where
    listToTuple3 :: [String] -> (Integer, Int, Int)
    listToTuple3 [x,y,z] = (read x, read y, read z)
    listToTuple3 _ = error "xxx"
    (yyyy, mm, dd) = listToTuple3 (splitOn "-" s)

