import MyList
import Board

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


main :: IO ()
main = do
  let boardInfo = emptyBoard boardSize
  roop boardInfo (winningPatterns boardSize) O
