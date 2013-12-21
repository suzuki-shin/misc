{-# OPTIONS_GHC -Wall #-}
import Control.Monad (guard)
import Control.Applicative ((<$>),(<*>))
import Data.Array (Array, listArray, assocs, (!), elems, (//))


data Direction = E | W | S | N deriving (Show, Eq)
type Pos = (Int,Int) -- (y,x)
type Tile = Char
type MapData = Array Pos Tile

-- | 読み込んだ文字列を2次元Arrayに変換する
stringTo2DArray :: Int -> Int -> String -> MapData
stringTo2DArray h w input = listArray ((0,0), (h,w)) $ filter (/='\n') input

printMapData :: Int -> MapData -> IO ()
printMapData width m = do
  let mStr = elems m
  printMapData' width mStr
  return ()
  where
    printMapData' :: Int -> String -> IO ()
    printMapData' _ "" = return ()
    printMapData' width s = do
      putStrLn $ take width s
      printMapData' width $ drop width s

-- | start位置座標を返す
startPos :: MapData -> Pos
startPos = posOf 'S'

-- | goal位置座標を返す
goalPos :: MapData -> Pos
goalPos = posOf 'G'

posOf :: Tile -> MapData -> Pos
posOf tile ar = fst $ head $ filter (\(_,t) -> t == tile) $ assocs ar

-- | 指定した位置から移動した次の位置のリストを返す (壁'*'には移動できない)
nextPoss :: MapData -> Int -> Int -> Pos -> [Pos]
nextPoss m height width p = do
  d <- [E,W,S,N]
  let p' = move d p
      y' = fst p'
      x' = snd p'
  guard $ (y' >= 0) && (y' < height) && (x' >= 0) && (x' < width)
  guard $ (m ! p') /= '*'
  return p'

move :: Direction -> Pos -> Pos
move E (y,x) = (y,x+1)
move W (y,x) = (y,x-1)
move S (y,x) = (y+1,x)
move N (y,x) = (y-1,x)

searchRoute :: MapData -> Int -> Int -> [Pos] -> Pos -> [[Pos]]
searchRoute m h w tracks currentP = do
  if (m ! currentP) == 'G'
     then return tracks
     else do
       if currentP `elem` tracks
         then []
         else do
           nextP <- nextPoss m h w currentP
           searchRoute m h w (currentP:tracks) nextP

main :: IO ()
main = do
  c <- getContents
  let height = length $ lines c
      width  = length $ head $ lines c
      a = stringTo2DArray (height - 1) (width - 1) c
      startP = startPos a
      b = searchRoute a height width [] startP
      minlen = minimum $ map length b
      b0 = filter (\r -> length r == minlen) b
      c0 = map (\p -> (p,'$')) $ head b0
  print height
  print width
  print minlen
  print $ startPos a
  print $ goalPos a
  if length b0 == 0
    then print "no route"
    else print $ head b0
  printMapData width $ a // c0
