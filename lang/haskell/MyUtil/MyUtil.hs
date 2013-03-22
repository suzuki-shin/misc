{-# OPTIONS_GHC -Wall #-}
module MyUtil (
    replace
  , replaceAll
  , splitOn                     -- Data.List.Split.splitOn
  ) where

import Data.List
import Data.List.Split (splitOn)

-- | 文字列中の文字列を置換する
replace :: String -> String -> String -> String
replace searchStr replaceStr  = intercalate replaceStr . splitOn searchStr

-- | (検索文字列, 置換文字列)というタプルのリストと対象文字列を受け取って、対象文字列中の検索文字列をすべて対応する置換文字列で置き換えた文字列を返す
replaceAll :: [(String, String)] -> String -> String
replaceAll [] s = s
replaceAll (m:ms) s = replaceAll ms (replace (fst m) (snd m) s)
