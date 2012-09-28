import MyList
import Board
import Data.Map

boardSize :: Int
boardSize = 4

data Direct = LeftUpD | UpD | RightUpD
            | LeftD | RightD
            | LeftDownD | DownD | RightDownD
            deriving (Show, Eq)
direct :: Pos -> Direct -> Pos
direct (x, y) dir
  | dir == LeftUpD = (x - 1, y - 1)
  | dir == UpD = (x, y - 1)
  | dir == RightUpD = (x + 1, y - 1)
  | dir == LeftD = (x - 1, y)
  | dir == RightD = (x + 1, y)
  | dir == LeftDownD = (x - 1, y + 1)
  | dir == DownD = (x, y - 1)
  | dir == RightDownD = (x + 1, y + 1)

isFinished :: Board -> Bool
isFinished board = length (marksPosOf board E) == 0

checkWin :: Board -> Mark -> Bool
checkWin board mark = isFinished board && length (marksPosOf board mark) > length (marksPosOf board (rev mark))

checkDraw :: Board -> Mark -> Bool
checkDraw board mark = isFinished board && length (marksPosOf board mark) == length (marksPosOf board (rev mark))

-- | そこにmarkを置いた場合あいてのmarkを挟めるか
canClip :: BoardInfo -> Pos -> Mark -> Bool
canClip boardInfo pos mark = case  byEnemySide (getBoard boardInfo) pos mark of
    Just dir -> canClip' (getBoard boardInfo) dir pos mark
      where
        -- 指定した方向の隣のMarkはmarkか、もしくはそこは逆のmarkでその向こうが自分のmarkか
        canClip' :: Board -> Direct -> Pos -> Mark -> Bool
        canClip' board dir pos mark
          | markOf board (direct pos dir) == Just mark = True
          |    (markOf board (direct pos dir) == Just (rev mark))
            && canClip' board dir (direct pos dir) mark = True
          | otherwise = False
    Nothing -> False


-- | となりに逆のマークがあるか？
-- >>> import Data.Map
-- >>> let b = (fromList [((1,1),O),((1,2),X)]) :: Board
-- >>> byEnemySide b (2,1) O
-- Just LeftDownD
-- >>> byEnemySide b (2,2) O
-- Just LeftD
-- >>> byEnemySide b (3,1) O
-- Nothing
-- >>> byEnemySide b (3,1) X
-- Nothing
-- >>> byEnemySide b (0,0) O
-- Nothing
-- >>> byEnemySide b (0,0) X
-- Just RightDownD
byEnemySide :: Board -> Pos -> Mark -> Maybe Direct
byEnemySide board pos mark
  | markOf board (direct pos RightD) == Just (rev mark) = Just RightD
  | markOf board (direct pos LeftD) == Just (rev mark) = Just LeftD
  | markOf board (direct pos DownD) == Just (rev mark) = Just DownD
  | markOf board (direct pos UpD) == Just (rev mark) = Just UpD
  | markOf board (direct pos RightDownD) == Just (rev mark) = Just RightDownD
  | markOf board (direct pos LeftDownD) == Just (rev mark) = Just LeftDownD
  | markOf board (direct pos RightUpD) == Just (rev mark) = Just RightUpD
  | markOf board (direct pos LeftUpD) == Just (rev mark) = Just LeftUpD
  | otherwise = Nothing

canPut :: BoardInfo -> Pos -> Mark -> Bool
canPut boardInfo pos mark  =    (isOnBoard (getSize boardInfo) pos)
                             && ((markOf (getBoard boardInfo) pos) == Just E)
                             && canClip boardInfo pos mark

action :: BoardInfo -> BoardInfo
action boardInfo = undefined

initBoard :: Int -> BoardInfo
initBoard size = BoardInfo size $ insert (3,3) O $ insert (3,2) X $ insert (2,3) X $ insert (2,2) O (getBoard (emptyBoard size))

main :: IO ()
main = do
  let boardInfo = initBoard boardSize
  roop boardInfo action canPut checkWin checkDraw O
