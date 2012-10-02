{-# OPTIONS -Wall #-}
import Board
import qualified Data.Map as M
import Data.Maybe
-- import Debug.Trace

boardSize :: Int
boardSize = 4

data Direct = LeftUpD | UpD | RightUpD
            | LeftD | RightD
            | LeftDownD | DownD | RightDownD
            deriving (Show, Eq)

-- | 指定PosのDirect方向の隣のPosを返す
-- >>> neighbor (1,1) LeftDownD
-- (0,2)
-- >>> neighbor (1,1) UpD
-- (1,0)
-- >>> neighbor (1,1) RightUpD
-- (2,0)
-- >>> neighbor (1,1) LeftD
-- (0,1)
-- >>> neighbor (1,1) RightD
-- (2,1)
-- >>> neighbor (1,1) LeftDownD
-- (0,2)
-- >>> neighbor (1,1) DownD
-- (1,2)
-- >>> neighbor (1,1) RightDownD
-- (2,2)
neighbor :: Pos -> Direct -> Pos
neighbor (x, y) dir
  | dir == LeftUpD    = (x - 1, y - 1)
  | dir == UpD        = (x, y - 1)
  | dir == RightUpD   = (x + 1, y - 1)
  | dir == LeftD      = (x - 1, y)
  | dir == RightD     = (x + 1, y)
  | dir == LeftDownD  = (x - 1, y + 1)
  | dir == DownD      = (x, y + 1)
  | dir == RightDownD = (x + 1, y + 1)
neighbor _ _ = error "bad args"

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
  | not (isOnBoard (getSize boardInfo) pos) || not (isOnBoard (getSize boardInfo) nextPos) || isNothing markOfNextPos = []
  | otherwise = (nextPos, fromJust markOfNextPos) : (lineOfDirection boardInfo nextPos dir)
  where
    nextPos = neighbor pos dir
    markOfNextPos = markOf (getBoard boardInfo) nextPos

-- | その(line::[(Pos,Mark)])は指定したmarkで挟めるlineか？はさめるならそのlineを、はさめないなら[]を返す
-- >>> clippableLine O [((2,1),X),((3,1),X),((4,1),O)]
-- [(2,1),(3,1)]
-- >>> clippableLine O [((2,1),O),((3,1),X),((4,1),O)]
-- []
-- >>> clippableLine O [((2,1),X),((3,1),X),((4,1),E)]
-- []
clippableLine :: Mark -> [(Pos, Mark)] -> [Pos]
clippableLine mark posMarks
  | length body < length posMarks && snd (posMarks!!(length body)) == mark = body
  | otherwise = []
  where
    body = body' mark posMarks
    body' mark' (pm:pms)
      | snd pm == rev mark' = (fst pm) : (body' mark' pms)
      | otherwise = []
    body' _ _ = []

-- | そこにmarkを置いた場合あいてのmarkを挟めるか
-- >>> let bSize = 4 :: Int
-- >>> let bi = BoardInfo bSize $ M.insert (3,3) O $ M.insert (3,2) X $ M.insert (2,3) X $ M.insert (2,2) O (getBoard (emptyBoard bSize))
canClip :: BoardInfo -> Pos -> Mark -> Bool
canClip bi p m
  | filter (\d -> clippableLine m (lineOfDirection bi p d) /= []) allDirections == [] = False
  | otherwise = True

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
  | markOf board (neighbor pos RightD) == Just (rev mark)     = Just RightD
  | markOf board (neighbor pos LeftD) == Just (rev mark)      = Just LeftD
  | markOf board (neighbor pos DownD) == Just (rev mark)      = Just DownD
  | markOf board (neighbor pos UpD) == Just (rev mark)        = Just UpD
  | markOf board (neighbor pos RightDownD) == Just (rev mark) = Just RightDownD
  | markOf board (neighbor pos LeftDownD) == Just (rev mark)  = Just LeftDownD
  | markOf board (neighbor pos RightUpD) == Just (rev mark)   = Just RightUpD
  | markOf board (neighbor pos LeftUpD) == Just (rev mark)    = Just LeftUpD
  | otherwise = Nothing

-- | そこにそのマークを置けるかどうか
-- >>> let bi = initBoard 4 [((2,2),O), ((2,3),X),((3,2),X), ((3,3),O)]
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
canPut boardInfo pos mark  =    isOnBoard (getSize boardInfo) pos
                             && (markOf (getBoard boardInfo) pos) == Just E
                             && canClip boardInfo pos mark

turnBack :: Board -> [Pos] -> Board
turnBack board ps = foldl (\b p -> M.insert p (revMark p) b) board ps
  where
    revMark :: Pos -> Mark
    revMark p = case M.lookup p board of
      Just (pos', mark') -> mark'
      Nothing -> 

-- | markをおいたあとにboardInfoがどのように変更されるか
action :: BoardInfo -> Pos -> Mark  -> BoardInfo
action boardInfo _ _ = BoardInfo (getSize boardInfo) (M.insert (4, 4) X (getBoard boardInfo))

initBoard :: Int -> [(Pos, Mark)] -> BoardInfo
initBoard bSize posMarks = BoardInfo bSize $ foldl (\b (pos, mark) -> M.insert pos mark b) (getBoard (emptyBoard bSize)) posMarks

main :: IO ()
main = do
  let boardInfo = initBoard boardSize [((2,2),O), ((2,3),X),((3,2),X), ((3,3),O)]
  roop boardInfo action canPut checkWin checkDraw O
