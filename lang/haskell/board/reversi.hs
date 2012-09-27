import MyList
import Board

boardSize :: Int
boardSize = 8

isFinished :: Board -> Bool
isFinished board = length (marksPosOf board E) == 0

checkWin :: Board -> Mark -> Bool
checkWin board mark = isFinished board && length (marksPosOf board mark) > length (marksPosOf board (rev mark))

checkDraw :: Board -> Mark -> Bool
checkDraw board mark = isFinished board && length (marksPosOf board mark) == length (marksPosOf board (rev mark))

canClip boardInfo pos = True

canPut :: BoardInfo -> Pos -> Bool
canPut boardInfo pos =    (isOnBoard (getSize boardInfo) pos)
                       && ((markOf (getBoard boardInfo) pos) == Just E)
                       && canClip boardInfo pos

action :: BoardInfo -> BoardInfo
action boardInfo = boardInfo -- 仮実装

main :: IO ()
main = do
  let boardInfo = emptyBoard boardSize
  roop boardInfo action checkWin checkDraw O
