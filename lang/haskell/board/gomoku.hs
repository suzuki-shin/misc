import MyList
import Board
-- import Debug.Trace

boardSize :: Int
boardSize = 15

winningPatterns :: Int -> [[Pos]]
winningPatterns boardSize = (_tate boardSize) ++ (_yoko boardSize) ++ (_naname boardSize)
  where
    _tate :: Int -> [[Pos]]
    _tate boardSize = [[(x,y),(x,y+1),(x,y+2),(x,y+3),(x,y+4)] | x <- [1..(boardSize)], y <- [1..(boardSize - 4)]]
    _yoko :: Int -> [[Pos]]
    _yoko boardSize = [[(x,y),(x+1,y),(x+2,y),(x+3,y),(x+4,y)] | x <- [1..(boardSize - 4)], y <- [1..(boardSize)]]
    _naname :: Int -> [[Pos]]
    _naname boardSize = [[(x,y),(x+1,y+1),(x+2,y+2),(x+3,y+3),(x+4,y+4)] | x <- [1..(boardSize - 4)], y <- [1..(boardSize - 4)]]
                        ++ [[(x,y),(x+1,y-1),(x+2,y-2),(x+3,y-3),(x+4,y-4)] | x <- [1..(boardSize - 4)], y <- [5..boardSize]]

win :: [[Pos]] -> Board -> Mark -> Bool
win winPtns board mark = win' (marksPosOf board mark) winPtns
  where
    win' :: [Pos] -> [[Pos]] -> Bool
--     win' marksPos (wp:winPtns') = trace ("wp: " ++show wp ++ "\n marksPos: " ++ show marksPos) ( (wp `isIn` marksPos) || (win' marksPos winPtns') )
    win' marksPos (wp:winPtns') = (wp `isIn` marksPos) || (win' marksPos winPtns')
    win' [] _ = False
    win' _ [] = False

draw board _ = length (marksPosOf board E) == 0


main :: IO ()
main = do
  let boardInfo = emptyBoard boardSize
  roop boardInfo id (win (winningPatterns boardSize)) draw O
