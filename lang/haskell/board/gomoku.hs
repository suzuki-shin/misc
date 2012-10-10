{-# OPTIONS -Wall #-}
import MyList
import Board
import System.Random
-- import Debug.Trace

boardSize :: Int
boardSize = 15

winningPatterns :: Int -> [[Pos]]
winningPatterns bSize = (_tate bSize) ++ (_yoko bSize) ++ (_naname bSize)
  where
    _tate :: Int -> [[Pos]]
    _tate bSize' = [[(x,y),(x,y+1),(x,y+2),(x,y+3),(x,y+4)] | x <- [1..(bSize')], y <- [1..(bSize' - 4)]]
    _yoko :: Int -> [[Pos]]
    _yoko bSize' = [[(x,y),(x+1,y),(x+2,y),(x+3,y),(x+4,y)] | x <- [1..(bSize' - 4)], y <- [1..(bSize')]]
    _naname :: Int -> [[Pos]]
    _naname bSize' = [[(x,y),(x+1,y+1),(x+2,y+2),(x+3,y+3),(x+4,y+4)] | x <- [1..(bSize' - 4)], y <- [1..(bSize' - 4)]]
                        ++ [[(x,y),(x+1,y-1),(x+2,y-2),(x+3,y-3),(x+4,y-4)] | x <- [1..(bSize' - 4)], y <- [5..bSize']]

win :: [[Pos]] -> Board -> Mark -> Bool
win winPtns board mark = win' (marksPosOf board mark) winPtns
  where
    win' :: [Pos] -> [[Pos]] -> Bool
--     win' marksPos (wp:winPtns') = trace ("wp: " ++show wp ++ "\n marksPos: " ++ show marksPos) ( (wp `isIn` marksPos) || (win' marksPos winPtns') )
    win' marksPos (wp:winPtns') = (wp `isIn` marksPos) || (win' marksPos winPtns')
    win' [] _ = False
    win' _ [] = False

draw :: Board -> t -> Bool
draw board _ = length (marksPosOf board E) == 0

lose :: Board -> t -> Bool
lose _ _ = False

-- | 指定したPosにMarkを置くことができるかどうかを返す
canPut :: BoardInfo -> Pos -> Mark -> Bool
canPut boardInfo pos _ = (isOnBoard (getSize boardInfo) pos) && ((markOf (getBoard boardInfo) pos) == Just E)

-- | 指定したMarkを置くことのできる全Posを返す
puttableAllPoses :: BoardInfo -> Mark -> [Pos]
puttableAllPoses bi m = filter (\p -> canPut bi p m) $ marksPosOf (getBoard bi) E

enemyAi :: Mark -> BoardInfo -> IO Pos
enemyAi m bi = do
  let ps = puttableAllPoses bi m
      psLen = length ps
  idx <- randomRIO (0, psLen-1)
  print ps
  return $ ps!!idx


main :: IO ()
main = do
  let boardInfo = emptyBoard boardSize
  roop boardInfo (\bi _ _ -> bi) canPut (win (winningPatterns boardSize)) draw lose O (enemyAi X)
