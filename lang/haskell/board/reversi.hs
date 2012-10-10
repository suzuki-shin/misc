{-# OPTIONS -Wall #-}
import Board
import qualified Data.Map as M
import Data.Maybe
import Control.Monad
import System.Random
-- import Debug.Trace

boardSize :: Int
boardSize = 8

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

checkLose :: Board -> Mark -> Bool
checkLose board mark = isFinished board && not (checkWin board mark) && not (checkDraw board mark)

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
  | not (any (\d -> clippableLine m (lineOfDirection bi p d) /= []) allDirections) = False
  | otherwise = True

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

-- | 指定した位置のmarkをひっくり返す
turnBack :: Board -> [Pos] -> Board
turnBack board ps = foldl (\b p -> M.insert p (revMark p) b) board ps
  where
    revMark :: Pos -> Mark
    revMark p = rev $ fromJust $ M.lookup p board

-- | markをおいたあとにboardInfoがどのように変更されるか
action :: BoardInfo -> Pos -> Mark  -> BoardInfo
action bi pos mark = BoardInfo bSize (turnBack b clippablePoses)
  where
    b = getBoard bi
    bSize = getSize bi
    dirs = filter (\d -> clippableLine mark (lineOfDirection bi pos d) /= []) allDirections
    clippablePoses = join $ map (\d -> clippableLine mark (lineOfDirection bi pos d)) dirs

initBoard :: Int -> [(Pos, Mark)] -> BoardInfo
initBoard bSize posMarks = BoardInfo bSize $ foldl (\b (pos, mark) -> M.insert pos mark b) (getBoard (emptyBoard bSize)) posMarks

-- | 指定したMarkを置くことのできる全Posを返す
puttableAllPoses :: BoardInfo -> Mark -> [Pos]
puttableAllPoses bi m = filter (\p -> canPut bi p m) $ marksPosOf (getBoard bi) E

-- | 相手の打つ場所を返す
enemyAi :: Mark -> BoardInfo -> IO Pos
enemyAi m bi = do
  let ps = puttableAllPoses bi m
  idx <- randomRIO (0, (length ps)-1)
  print ps
  return $ ps!!idx


main :: IO ()
main = roop boardInfo action canPut checkWin checkDraw checkLose O (enemyAi X)
  where
    center = boardSize `div` 2
    initMarkPos = [((center,center),O), ((center,center+1),X),((center+1,center),X), ((center+1,center+1),O)]
    boardInfo = initBoard boardSize initMarkPos
