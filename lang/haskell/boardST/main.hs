{-# OPTIONS_GHC -Wall #-}
import Control.Monad.State
import Control.Applicative ((<$>),(<*>))
import Data.List.Split (splitOn)
import Data.Array (Array, listArray, (//), (!))
import Data.Maybe (fromJust)

main :: IO ()
main = do
  print "xxx"
  let (a,b) = runState (putMark O (1,1)) emptyBoard
  print "yyy"
  -- print b

data Mark = E | X | O deriving (Eq)
instance Show Mark where
  show E = "_"
  show O = "O"
  show X = "X"

type Pos = (Int,Int)
type Board = Array Pos Mark
data Result = Lose | Draw | Win

-- | 2次元配列を(座標, 値)のarrayに変換(array版)
-- >>> to2DArray [["0","0","0","0","0","0"],["0","1","1","0","0","0"],["0","1","0","0","0","0"],["0","0","0","0","1","0"],["0","0","0","1","0","0"],["0","0","0","0","0","0"]]
-- array ((0,0),(5,5)) [((0,0),"0"),((0,1),"0"),((0,2),"0"),((0,3),"0"),((0,4),"0"),((0,5),"0"),((1,0),"0"),((1,1),"1"),((1,2),"1"),((1,3),"0"),((1,4),"0"),((1,5),"0"),((2,0),"0"),((2,1),"1"),((2,2),"0"),((2,3),"0"),((2,4),"0"),((2,5),"0"),((3,0),"0"),((3,1),"0"),((3,2),"0"),((3,3),"0"),((3,4),"1"),((3,5),"0"),((4,0),"0"),((4,1),"0"),((4,2),"0"),((4,3),"1"),((4,4),"0"),((4,5),"0"),((5,0),"0"),((5,1),"0"),((5,2),"0"),((5,3),"0"),((5,4),"0"),((5,5),"0")]
to2DArray :: Show a => [[a]] -> Array (Int,Int) a
to2DArray ss = listArray ((0,0),(width - 1 ,height - 1)) $ concat ss
  where
    height = length $ ss
    width = length $ head $ ss

-- | ボード初期か
emptyBoard :: Board
emptyBoard = to2DArray $ replicate 3 $ replicate 3 E

{-
-}
putMark :: Mark -> Pos -> State Board ()
putMark mark pos = do
  board <- get
  put $ board // [(pos,mark)]

-- putMark :: Mark -> Pos -> Maybe (State Board ())
-- putMark mark pos = do
--   board <- get
--   if canPut mark pos board
--     then Just $ put $ board // [(pos,mark)]
--     else Nothing

canPut :: Mark -> Pos -> Board -> Bool
canPut mark pos board = (pos `isOn` board) && (pos `isEmpty` board)
  -- state $ \s -> posIsOnBoard
  -- where
  --   posIsOnBoard = if isOnBoard pos
  --     then if isEmptyPos pos
  --            then True
  --            else False
  --     else False

isOn :: Pos -> Board -> Bool
isOn (y,x) board = (y <= maxY) && (x <= maxX)
  where
    (maxY, maxX) = bound board

bound :: Board -> (Int, Int)
bound _ = (3,3)

isEmpty :: Pos -> Board -> Bool
isEmpty pos board = (board ! pos) == E
