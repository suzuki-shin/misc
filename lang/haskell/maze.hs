{-# OPTIONS_GHC -Wall #-}
-- 人材獲得作戦・４  試験問題ほか

--   さて試験問題です。
--   内容は、壁とスペースで構成された迷路が与えられたとき、スタート地点からゴール地点に至る最短経路を求めよ、というものです。
--   たとえば、S:スタート  G:ゴール  *:壁  $:解答の経路  としたとき、

-- **************************
-- *S* *                    *
-- * * *  *  *************  *
-- * *   *    ************  *
-- *    *                   *
-- ************** ***********
-- *                        *
-- ** ***********************
-- *      *              G  *
-- *  *      *********** *  *
-- *    *        ******* *  *
-- *       *                *
-- **************************
-- という入力に対し、

-- **************************
-- *S* * $$$                *
-- *$* *$$*$ *************  *
-- *$* $$* $$$************  *
-- *$$$$*    $$$$$          *
-- **************$***********
-- * $$$$$$$$$$$$$          *
-- **$***********************
-- * $$$$$*$$$$$$$$$$$$$$G  *
-- *  *  $$$ *********** *  *
-- *    *        ******* *  *
-- *       *                *
-- **************************
--   という出力が来ればOK、というわけです。（ブラウザだと見づらいかもしれないのでテキストエディタ等にコピーすれば見やすくなります）

--   もうちょっと細かい条件としては、
-- ●入出力はテキストデータを用いる
-- ●一度に動けるのは上下左右のみ。斜めは不可
-- ●最短経路が複数あるときはそのうちの１つが出力されていればOK
-- ●入力データのバリデーション（長方形になっているか、スタート・ゴールが１つずつあるかどうか、等）は不要
-- ●制限時間は３時間
-- ●プログラム言語・OSは自由

import Control.Applicative ((<$>), (<*>))
import Data.Array
import Data.Maybe (catMaybes)

type Pos = (Int,Int)
type MapData = Array Pos Char

-- data Tile = Wall | Start | Goal | Road deriving (Show, Eq)
data Direct = LeftD | UpD | RightD | DownD deriving (Show, Eq, Enum)

-- charToTile :: Char -> Tile
-- charToTile '*' = Wall
-- charToTile 'S' = Start
-- charToTile ' ' = Road
-- charToTile 'G' = Goal
-- charToTile _ = error "xxx"

to2DArray :: Show a => [[a]] -> Array (Int,Int) a
to2DArray ss = listArray ((0,0),(maxX ,maxY)) $ concat ss


move' :: MapData -> Pos -> Direct -> Maybe Pos
move' m (x,y) LeftD = if x-1 >= 0
                         then case m ! (x-1,y) of
                                '*' -> Nothing
                                _ -> Just (x-1,y)
                         else Nothing
move' m (x,y) UpD = if y-1 >= 0
                         then case m ! (x,y-1) of
                                '*' -> Nothing
                                _ -> Just (x,y-1)
                         else Nothing
move' m (x,y) RightD = if x+1 <= maxX
                         then case m ! (x+1,y) of
                                '*' -> Nothing
                                _ -> Just (x+1,y)
                         else Nothing
move' m (x,y) DownD = if y+1 <= maxY
                         then case m ! (x,y+1) of
                                '*' -> Nothing
                                _ -> Just (x,y+1)
                         else Nothing

move :: MapData -> Pos -> [Pos]
move m (x,y) = catMaybes $ map (move' m (x,y)) [LeftD ..]

-- tile :: MapData -> Pos -> Tile
-- tile m p = m ! p

maxX, maxY :: Int
maxX = 13 -- 仮
maxY = 13 -- 仮
startPos :: Pos
startPos = (1,1) -- 仮
goalPos :: Pos
goalPos = (11,9) -- 仮
-- mapData :: MapData
-- mapData = listArray ((0,0),(2,2)) $ "***S G   **   ** *   "

-- ゴールに到達する全てのルートを求める
searchRoute :: MapData -> Pos -> [Pos] -> [[Pos]]
searchRoute m pos route =
  if isBadRoute pos route
    then return []
    else do
      pos' <- move m pos
      if pos' == goalPos
        then return $ goalPos:pos:route
        else searchRoute m pos' (pos:route)
  where
    isBadRoute :: Pos -> [Pos] -> Bool
    isBadRoute status route' = status `elem` route' -- 既に通った状態はダメ

main :: IO ()
main = do
  mapData <- to2DArray <$> lines <$> getContents
  print mapData
  mapM_ print $ filter (/=[]) (searchRoute mapData startPos [])

-- main :: IO ()
-- main = do
--   ls <- lines <$> getContents
--   print $ to2DArray ls

