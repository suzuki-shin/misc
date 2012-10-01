{-# OPTIONS -Wall #-}
import MyList (isIn)
import Board

boardSize :: Int
boardSize = 3

winningPatterns :: [[Pos]]
winningPatterns = [[(1,1),(1,2),(1,3)], [(2,1),(2,2),(2,3)], [(3,1),(3,2),(3,3)], -- 横
                   [(1,1),(2,1),(3,1)], [(1,2),(2,2),(3,2)], [(1,3),(2,3),(3,3)], -- 縦
                   [(1,1),(2,2),(3,3)], [(3,1),(2,2),(1,3)]] -- 斜

win :: [[Pos]] -> Board -> Mark -> Bool
win winPtns board mark = win' (marksPosOf board mark) winPtns
  where
    win' :: [Pos] -> [[Pos]] -> Bool
--     win' marksPos (wp:winPtns') = trace ("wp: " ++show wp ++ "\n marksPos: " ++ show marksPos) ( (wp `isIn` marksPos) || (win' marksPos winPtns') )
    win' marksPos (wp:winPtns') = (wp `isIn` marksPos) || (win' marksPos winPtns')
    win' [] _ = False
    win' _ [] = False

draw :: Board -> Mark -> Bool
draw board _ = length (marksPosOf board E) == 0

-- | 指定したPosにMarkを置くことができるかどうかを返す
canPut :: BoardInfo -> Pos -> Mark -> Bool
canPut boardInfo pos _ = (isOnBoard (getSize boardInfo) pos) && ((markOf (getBoard boardInfo) pos) == Just E)

main :: IO ()
main = do
  let boardInfo = emptyBoard boardSize
  roop boardInfo (\bi _ _ -> bi) canPut (win winningPatterns) draw O
