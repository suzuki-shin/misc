{-# OPTIONS -Wall #-}
import Board
import qualified Data.Map as M
import Data.Maybe
import Debug.Trace

boardSize :: Int
boardSize = 4

data Direct = LeftUpD | UpD | RightUpD
            | LeftD | RightD
            | LeftDownD | DownD | RightDownD
            deriving (Show, Eq)
direct :: Pos -> Direct -> Pos
direct (x, y) dir
  | dir == LeftUpD    = (x - 1, y - 1)
  | dir == UpD        = (x, y - 1)
  | dir == RightUpD   = (x + 1, y - 1)
  | dir == LeftD      = (x - 1, y)
  | dir == RightD     = (x + 1, y)
  | dir == LeftDownD  = (x - 1, y + 1)
  | dir == DownD      = (x, y - 1)
  | dir == RightDownD = (x + 1, y + 1)
direct _ _ = error "bad args"

allDirections :: [Direct]
allDirections = [ LeftUpD, UpD , RightUpD
                , LeftD, RightD
                , LeftDownD, DownD, RightDownD]

isFinished :: Board -> Bool
isFinished board = length (marksPosOf board E) == 0

checkWin :: Board -> Mark -> Bool
checkWin board mark = isFinished board && length (marksPosOf board mark) > length (marksPosOf board (rev mark))

checkDraw :: Board -> Mark -> Bool
checkDraw board mark = isFinished board && length (marksPosOf board mark) == length (marksPosOf board (rev mark))

-- | 指定した位置から指定した方向の列の(Pos,Mark)のリストを返す
-- >>> let bSize = 4 :: Int
-- >>> let bi = BoardInfo bSize $ M.insert (3,3) O $ M.insert (3,2) X $ M.insert (2,3) X $ M.insert (2,2) O (getBoard (emptyBoard bSize))
-- >>> lineOfDirection bi (3,3) UpD
-- [((3,2),X),((3,1),_)]
-- >>> lineOfDirection bi (3,3) LeftUpD
-- [((2,2),O),((1,1),_)]
-- >>> lineOfDirection bi (4,4) LeftUpD
-- [((3,3),O),((2,2),O),((1,1),_)]
-- >>> lineOfDirection bi (4,3) LeftUpD
-- [((3,2),X),((2,1),_)]
-- >>> lineOfDirection bi (4,3) RightD
-- []
lineOfDirection :: BoardInfo -> Pos -> Direct -> [(Pos, Mark)]
lineOfDirection boardInfo pos dir
  |    isOnBoard (getSize boardInfo) pos == False
    || isOnBoard (getSize boardInfo) nextPos == False
    || isNothing markOfNextPos = []
  | otherwise = (nextPos, fromJust markOfNextPos) : (lineOfDirection boardInfo nextPos dir)
  where
    nextPos = direct pos dir
    markOfNextPos = markOf (getBoard boardInfo) nextPos

-- | その(line::[(Pos,Mark)])は指定したmarkで挟めるlineか？はさめるならそのlineを、はさめないなら[]を返す
isClipableLine :: Mark -> [(Pos, Mark)] -> [(Pos, Mark)]
isClipableLine mark line = let revLine = takeWhile (\(_, m) -> m == (rev mark)) line
                               lastPosMark = line!!(length revLine)
                               -- | 逆markのline
                               clipableLine :: Mark -> [(Pos, Mark)] -> [(Pos, Mark)]
                               clipableLine mark line = revLine ++ [lastPosMark]
                           in case (snd lastPosMark) /= mark of
                             False -> []
                             True -> clipableLine mark line

-- | そこにmarkを置いた場合あいてのmarkを挟めるか
canClip :: BoardInfo -> Pos -> Mark -> Bool
canClip _ _ _ = undefined
-- canClip boardInfo pos mark = map (lineOfDirection boardInfo pos) allDirections

-- canClip board pos mark = case byEnemySide board pos mark of
--   Just dir -> canClip' board dir pos mark
--     where
--       -- 指定した方向の隣のMarkはmarkか、もしくはそこは逆のmarkでその向こうが自分のmarkか
--       canClip' :: Board -> Direct -> Pos -> Mark -> Bool
--       canClip' board' dir' pos' mark'
--         | markOf board' (direct pos' dir') == Just mark' = True
--         |    (markOf board' (direct pos' dir') == Just (rev mark'))
--           && canClip' board' dir' (direct pos' dir') mark' = True
--         | otherwise = False
--   Nothing -> False

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
  | markOf board (direct pos RightD) == Just (rev mark)     = Just RightD
  | markOf board (direct pos LeftD) == Just (rev mark)      = Just LeftD
  | markOf board (direct pos DownD) == Just (rev mark)      = Just DownD
  | markOf board (direct pos UpD) == Just (rev mark)        = Just UpD
  | markOf board (direct pos RightDownD) == Just (rev mark) = Just RightDownD
  | markOf board (direct pos LeftDownD) == Just (rev mark)  = Just LeftDownD
  | markOf board (direct pos RightUpD) == Just (rev mark)   = Just RightUpD
  | markOf board (direct pos LeftUpD) == Just (rev mark)    = Just LeftUpD
  | otherwise = Nothing

-- | そこにそのマークを置けるかどうか
-- >>> let bi = initBoard 4
-- >>> canPut bi (1,3) O
-- True
-- >>> canPut bi (1,2) X
-- True
-- >>> canPut bi (1,3) X
-- False
canPut :: BoardInfo -> Pos -> Mark -> Bool
-- canPut boardInfo pos mark  =    trace("is not OnBoard") ((isOnBoard (getSize boardInfo) pos))
--                              && trace("not E") (((markOf (getBoard boardInfo) pos) == Just E))
--                              && trace("can not clip") (canClip boardInfo pos mark)
canPut boardInfo pos mark  =    (isOnBoard (getSize boardInfo) pos)
                             && ((markOf (getBoard boardInfo) pos) == Just E)
                             && trace "### can not clip ###" (canClip boardInfo pos mark)

-- | markをおいたあとにboardInfoがどのように変更されるか
action :: BoardInfo -> Pos -> Mark  -> BoardInfo
-- action boardInfo pos mark = BoardInfo (getSize boardInfo) (M.insert (4, 4) X (getBoard boardInfo))
action boardInfo _ _ = BoardInfo (getSize boardInfo) (M.insert (4, 4) X (getBoard boardInfo))

initBoard :: Int -> [(Pos, Mark)] -> BoardInfo
initBoard bSize posMarks = BoardInfo bSize $ foldl (\b (pos, mark) -> M.insert pos mark b) (getBoard (emptyBoard bSize)) posMarks

main :: IO ()
main = do
  let boardInfo = initBoard boardSize [((2,2),O), ((2,3),X),((3,2),X), ((3,3),O)]
  roop boardInfo action canPut checkWin checkDraw O
