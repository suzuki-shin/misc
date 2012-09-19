module OX where

import qualified Data.Map as M

data State = E | O | X deriving (Show, Eq)
type Pos = (Int, Int)
type Board = M.Map Pos State

size :: Int
size = 3

initBoard :: Board
initBoard = M.fromList [((x, y) , E) | x <- [1..size], y <- [1..size]]

rev :: State -> State
rev O = X
rev X = O
rev E = E

canPut :: Board -> Pos -> Bool
canPut b p = (onBoard p) && (M.lookup p b == Just E)

onBoard :: Pos -> Bool
onBoard (x, y) = (x >= 1 && x <= size) && (y >= 1 && y <= size)

put :: Board -> Pos -> State -> Either String Board
put b p s
  | onBoard p = if canPut b p
                then Right (M.insert p s b)
                else Left "can't put there."
  | otherwise = Left "out of board."

roop :: Board -> State -> IO b
roop board state = do
  putStrLn "---"
  renderBoard board
  putStrLn "---"
  board' <- tern board state
  case board' of
    Right board1 -> roop board1 (rev state)
    Left err -> do
      print err
      roop board state

tern :: Board -> State -> IO (Either String Board)
tern b s = do
  [x, y] <- inputToPos
  let b' = put b ((read x , read y) :: (Int, Int)) s
  return b'
    where
      inputToPos = do
        l <- getLine
        if length (words l) == 2
          then return $ words l
          else inputToPos

renderBoard :: M.Map Pos State -> IO ()
renderBoard board = mapM_ renderCol $ M.toList board
  where
    renderCol :: (Pos, State) -> IO ()
    renderCol ((x,y), state)
      | y == 3 = putStrLn $ show state
      | otherwise = putStr $ show state

main :: IO ()
main = do
  let b = initBoard
  roop b O

