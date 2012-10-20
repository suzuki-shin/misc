{-# OPTIONS -Wall #-}

import qualified Data.Map as M
import Data.List
import Data.Ord
import Control.Monad

data MapChip = Wall | Empty | Start | Goal | MyRoot deriving (Show, Eq)
type Pos = (Int, Int)
type RootMap = M.Map Pos MapChip -- 入力された地図
type Root = [Pos]                -- ルート(たどったPosのスタック)

data Direct = LeftD | UpD | RightD | DownD deriving (Show, Eq)

startPos :: RootMap -> Pos
startPos rootMap = fst . head $ M.toList $ M.filter (Start ==) rootMap
goalPos :: RootMap -> Pos
goalPos rootMap = fst . head $ M.toList $ M.filter (Goal ==) rootMap

allDirects :: [Direct]
allDirects = [LeftD, UpD, RightD, DownD]

charToMapChip :: Char -> MapChip
charToMapChip c = case c of
  '*' -> Wall
  ' ' -> Empty
  'S' -> Start
  'G' -> Goal
  '$' -> MyRoot
  _ -> error $ show c

mapChipToChar :: MapChip -> Char
mapChipToChar mc = case mc of
  Wall  -> '*'
  Empty -> ' '
  Start -> 'S'
  Goal  -> 'G'
  MyRoot -> '$'
  _ -> error $ show mc

neighbor :: Pos -> Direct -> Pos
neighbor (x,y) LeftD = (x-1,y)
neighbor (x,y) UpD = (x,y-1)
neighbor (x,y) RightD = (x+1,y)
neighbor (x,y) DownD = (x,y+1)

moveOk :: RootMap -> Root -> Pos -> Bool
moveOk rootMap root pos = case M.lookup pos rootMap of
  Just Goal -> True
  Just Empty -> pos `notElem` root
  _ -> False

goal :: RootMap -> Pos -> Bool
goal rMap pos = goalPos rMap == pos
-- goal rootMap pos = case M.lookup pos rootMap of
--   Just Goal -> True
--   _ -> False

movableDirects :: RootMap -> Root -> Pos -> [Direct]
movableDirects rootMap root pos = filter (\d -> moveOk rootMap root (neighbor pos d)) allDirects

-- | 次にいけるPosを返すを追加したRootのリストを返す
move :: RootMap -> Root -> [Root]
move rootMap root = map (:root) neighbors
  where
    curPos = (head root)
    neighbors = map (neighbor curPos) $ movableDirects rootMap root curPos
-- move _ [] = [startPos]

-- | あー、全然おかしかった。まず最短もとめてないし、複数のRootも求めてない
reachableRoot :: RootMap -> Root -> [Root]
reachableRoot rootMap root = do
  root' <- move rootMap root
  if goal rootMap (head root')
    then return root'
    else reachableRoot rootMap root'


main = do
  input <- getContents
  putStrLn input
  let rMap = strToRootMap input
  print rMap
  let rs = reachableRoot rMap [startPos rMap]
  print rs
  let mergeR = mergeRoot rMap (rs!!0)
  print mergeR
  putStrLn $ rootMapToStr mergeR


-- | mapデータ読み込み用
strToRootMap :: String -> RootMap
strToRootMap input = M.fromList $ linesToPMs (lines input) (0,0)
  where
    linesToPMs :: [String] -> Pos -> [(Pos, MapChip)]
    linesToPMs (l:ls) (x,y) = (lineToPMs l (x,y)) ++ (linesToPMs ls (x,y+1))
    linesToPMs [] _ = []

    lineToPMs :: String -> Pos -> [(Pos, MapChip)]
    lineToPMs (c:cs) (x,y) = ((x,y), charToMapChip c) : lineToPMs cs (x+1,y)
    lineToPMs [] _ = []

-- | mapデータ出力用
rootMapToStr :: RootMap -> String
rootMapToStr rMap = foldl1' (\a b -> a ++ "\n" ++ b) $ map pMsToLine $ sortWithPos $ M.toList rMap
  where
    pMsToLine :: [(Pos, MapChip)] -> String
    pMsToLine [] = ""
    pMsToLine ((_, mc):pms) = mapChipToChar mc : pMsToLine pms

-- | Posのx,yで2次元に並べる
-- >>> sortWithPos [((1,2),Wall),((2,2),Empty),((2,1),Start),((1,1),Goal)]
-- [[],[((1,1),Goal),((2,1),Start)],[((1,2),Wall),((2,2),Empty)]]
sortWithPos :: [(Pos, MapChip)] ->[[(Pos, MapChip)]]
sortWithPos pms = map (sortByX . (rowOf pms)) [0..maxY]
  where
    rowOf :: [(Pos, MapChip)] -> Int  -> [(Pos, MapChip)]
    rowOf pms' n = filter (\((_,y),_) -> y == n) pms'
    sortByX :: [(Pos, MapChip)] -> [(Pos, MapChip)]
    sortByX = sortBy (comparing (fst . fst))
    maxY = maximum $ map (snd . fst) pms

-- | 経路のRootをプロットしたRootMapを返す
mergeRoot :: RootMap -> Root -> RootMap
mergeRoot rMap (p:ps) = mergeRoot (M.insert p MyRoot rMap) ps
mergeRoot rMap [] = rMap