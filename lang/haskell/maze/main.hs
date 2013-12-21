{-# OPTIONS_GHC -Wall #-}
import Control.Monad (guard)
import Data.Array (Array, listArray, assocs, (!), elems, (//))


data Direction = E | W | S | N deriving (Show, Eq)
type Pos = (Int,Int) -- (y,x)
type Tile = Char
-- type MapData = Array Pos Tile
data MapData = MapData {mapData :: Array Pos Tile, height :: Int, width :: Int}

-- | 読み込んだ文字列を2次元Arrayに変換する
stringTo2DArray :: Int -> Int -> String -> MapData
stringTo2DArray h w input = MapData (listArray ((0,0), (h,w)) $ filter (/='\n') input) h w

printMapData :: MapData -> IO ()
printMapData (MapData m _ w) = do
  let mStr = elems m
  printMapData' w mStr
  return ()
  where
    printMapData' :: Int -> String -> IO ()
    printMapData' _ "" = return ()
    printMapData' w' s = do
      putStrLn $ take w' s
      printMapData' w' $ drop w' s

-- | start位置座標を返す
startPos :: MapData -> Pos
startPos = posOf 'S'

-- | goal位置座標を返す
goalPos :: MapData -> Pos
goalPos = posOf 'G'

posOf :: Tile -> MapData -> Pos
posOf tile (MapData ar _ _) = fst $ head $ filter (\(_,t) -> t == tile) $ assocs ar

-- | 指定した位置から移動した次の位置のリストを返す (壁'*'には移動できない)
nextPoss :: MapData -> Pos -> [Pos]
nextPoss (MapData m h w) p = do
  d <- [E,W,S,N]
  let p' = move d p
      y' = fst p'
      x' = snd p'
  guard $ (y' >= 0) && (y' < h) && (x' >= 0) && (x' < w)
  guard $ (m ! p') /= '*'
  return p'

move :: Direction -> Pos -> Pos
move E (y,x) = (y,x+1)
move W (y,x) = (y,x-1)
move S (y,x) = (y+1,x)
move N (y,x) = (y-1,x)

searchRoute :: MapData -> [Pos] -> Pos -> [[Pos]]
searchRoute m tracks currentP = do
  if ((mapData m) ! currentP) == 'G'
     then return tracks
     else do
       if currentP `elem` tracks
         then []
         else do
           nextP <- nextPoss m currentP
           searchRoute m (currentP:tracks) nextP

main :: IO ()
main = do
  c <- getContents
  let h = length $ lines c
      w  = length $ head $ lines c
      mData = stringTo2DArray (h - 1) (w - 1) c
      routes = searchRoute mData [] $ startPos mData
      minlen = minimum $ map length routes
      minRoutes = filter (\r -> length r == minlen) routes
      minRoute = if length minRoutes == 0 then [] else head minRoutes
  printMapData $ MapData ((mapData mData) // init (map (\p -> (p,'$')) $ minRoute)) h w
