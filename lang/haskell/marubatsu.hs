module Marubatsh where

import qualified Data.List as L

data State = Empty | O | X deriving (Show, Eq)
type Pos = (Int, Int)
type Board = [(Pos, State)]

size :: Int
size = 3

initBoard :: Board
initBoard = [((x, y) , Empty) | x <- [1..size], y <- [1..size]]

canPut :: Board -> Pos -> Bool
canPut b p = (onBoard p) && (L.lookup p b == Just Empty)

onBoard :: Pos -> Bool
onBoard (x, y) = (x >= 1 && x <= size) && (y >= 1 && y <= size)

put :: Board -> Pos -> State -> Either String Board
put b p s
  | onBoard p = if canPut b p then Right b else Left "can put there."
  | otherwise = Left "out of board."