{-# OPTIONS_GHC -Wall #-}
module MyUtil (
    replace
  , replaceAll
  , splitOn                     -- Data.List.Split.splitOn
  , isIn
  , toCoordsAndValue
  , to2DArray
  , groupn
  , traverseDir
  ) where

import Data.List
import Data.List.Split (splitOn)
import Data.Array (Array, listArray)
import System.Directory (getDirectoryContents)
import System.Posix.Files (getFileStatus, isDirectory)
import Control.Monad (forM)
import Control.Applicative ((<$>))
import System.FilePath ((</>))

-- | 文字列中の文字列を置換する
-- >>> replace "hoge" "HOGE" "jkgehoge fuho geHo hohogerk"
-- "jkgeHOGE fuho geHo hoHOGErk"
-- >>> replace "hoge" "" "jkgehoge fuho geHo hohogerk"
-- "jkge fuho geHo hork"
-- >>> replace "" "HOge" "hohoge"
-- "hohoge"
replace :: String -> String -> String -> String
replace "" _  = id
replace searchStr replaceStr  = intercalate replaceStr . splitOn searchStr

-- | (検索文字列, 置換文字列)というタプルのリストと対象文字列を受け取って、対象文字列中の検索文字列をすべて対応する置換文字列で置き換えた文字列を返す
replaceAll :: [(String, String)] -> String -> String
replaceAll [] s = s
replaceAll (m:ms) s = replaceAll ms (replace (fst m) (snd m) s)

-- | あるリストの全ての要素が別のリストに含まれるかを返す(並び順は問わない)
-- >>> [1,2,3] `isIn` [3,1,2,4,5]
-- True
-- >>> [1,2,3] `isIn` [1,2,4,5]
-- False
-- >>> [] `isIn` [1,2,4,5]
-- True
-- >>> [] `isIn` []
-- True
-- >>> [(1,2),(2,3)] `isIn` [(3,3),(1,2),(4,5),(2,3)]
-- True
isIn :: Eq a => [a] -> [a] -> Bool
(x:xs) `isIn` ys = (x `elem` ys) && (xs `isIn` ys)
[] `isIn` _ = True

-- | 2次元配列を(座標, 値)のリストに変換
-- >>> toCoordsAndValue [["0","0","0","0","0","0"],["0","1","1","0","0","0"],["0","1","0","0","0","0"],["0","0","0","0","1","0"],["0","0","0","1","0","0"],["0","0","0","0","0","0"]]
-- [((0,0),"0"),((0,1),"0"),((0,2),"0"),((0,3),"0"),((0,4),"0"),((0,5),"0"),((1,0),"0"),((1,1),"1"),((1,2),"1"),((1,3),"0"),((1,4),"0"),((1,5),"0"),((2,0),"0"),((2,1),"1"),((2,2),"0"),((2,3),"0"),((2,4),"0"),((2,5),"0"),((3,0),"0"),((3,1),"0"),((3,2),"0"),((3,3),"0"),((3,4),"1"),((3,5),"0"),((4,0),"0"),((4,1),"0"),((4,2),"0"),((4,3),"1"),((4,4),"0"),((4,5),"0"),((5,0),"0"),((5,1),"0"),((5,2),"0"),((5,3),"0"),((5,4),"0"),((5,5),"0")]
toCoordsAndValue :: [[a]] -> [((Int,Int), a)]
toCoordsAndValue = concatMap toPosValueList . (zip [0..]) . (map (zip [0..]))
  where
    toPosValueList :: (Int, [(Int, a)]) -> [((Int,Int), a)]
    toPosValueList (_, []) = []
    toPosValueList (y, a:as) = ((y, (fst a)), (snd a)) : toPosValueList (y, as)

-- | 2次元配列を(座標, 値)のarrayに変換(array版)
-- >>> to2DArray [["0","0","0","0","0","0"],["0","1","1","0","0","0"],["0","1","0","0","0","0"],["0","0","0","0","1","0"],["0","0","0","1","0","0"],["0","0","0","0","0","0"]]
-- array ((0,0),(5,5)) [((0,0),"0"),((0,1),"0"),((0,2),"0"),((0,3),"0"),((0,4),"0"),((0,5),"0"),((1,0),"0"),((1,1),"1"),((1,2),"1"),((1,3),"0"),((1,4),"0"),((1,5),"0"),((2,0),"0"),((2,1),"1"),((2,2),"0"),((2,3),"0"),((2,4),"0"),((2,5),"0"),((3,0),"0"),((3,1),"0"),((3,2),"0"),((3,3),"0"),((3,4),"1"),((3,5),"0"),((4,0),"0"),((4,1),"0"),((4,2),"0"),((4,3),"1"),((4,4),"0"),((4,5),"0"),((5,0),"0"),((5,1),"0"),((5,2),"0"),((5,3),"0"),((5,4),"0"),((5,5),"0")]
to2DArray :: Show a => [[a]] -> Array (Int,Int) a
to2DArray ss = listArray ((0,0),(width - 1 ,height - 1)) $ concat ss
  where
    height = length $ ss
    width = length $ head $ ss

-- http://d.hatena.ne.jp/ha-tan/20061021/1161442240
-- | リストを定数個ごとに分割する
groupn :: Int -> [a] -> [[a]]
groupn _ [] = []
groupn n xs =
  let (xs1, xs2) = splitAt n xs
  in xs1 : groupn n xs2

-- | 指定したディレクトリを走査して、ファイルならactionを実行し、ディレクトリなら再帰的に走査する
traverseDir :: FilePath -> (FilePath -> IO ()) -> IO ()
traverseDir dirPath action = do
  files <- filter (\f -> not (f `elem` [".",".."])) <$> getDirectoryContents dirPath
  forM files $ \f -> do
    let fullfilePath = dirPath </> f
    st <- getFileStatus fullfilePath
    if (isDirectory st)
      then traverseDir fullfilePath action
      else action fullfilePath
  return ()
