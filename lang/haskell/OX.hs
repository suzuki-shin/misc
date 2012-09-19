module OX where

import qualified Data.Map as M

data State = E | O | X deriving (Show, Eq)
type Pos = (Int, Int)
type Board = M.Map Pos State

boardSize :: Int
boardSize = 3

initBoard :: Board
initBoard = M.fromList [((x, y) , E) | x <- [1..boardSize], y <- [1..boardSize]]

rev :: State -> State
rev O = X
rev X = O
rev E = E

canPut :: Board -> Pos -> Bool
canPut board pos = (onBoard pos) && (M.lookup pos board == Just E)

onBoard :: Pos -> Bool
onBoard (x, y) = (x >= 1 && x <= boardSize) && (y >= 1 && y <= boardSize)

put :: Board -> Pos -> State -> Either String Board
put board pos state
  | onBoard pos = if canPut board pos
                then Right (M.insert pos state board)
                else Left "can't put there."
  | otherwise = Left "out of board."

roop :: Board -> State -> IO b
roop board state = do
  renderBoard board
  board' <- tern board state
  case board' of
    Right board1 -> roop board1 (rev state)
    Left err -> do
      print err
      roop board state

-- 標準入力から座標を入力させて、正しい入力でない場合は正しくなるまで繰り返す
tern :: Board -> State -> IO (Either String Board)
tern board state = do
  [x, y] <- inputToPos
  return $ put board ((read x , read y) :: (Int, Int)) state
    where
      inputToPos = do
        l <- getLine
        if length (words l) == 2
          then return $ words l
          else inputToPos

renderBoard :: M.Map Pos State -> IO ()
renderBoard board = do
  putStrLn " 123\n ---"
  mapM_ renderCol $ M.toList board
  putStrLn " ---\n"
  where
    renderCol :: (Pos, State) -> IO ()
    renderCol ((x,y), state)
      | y == 1 = putStr $ " " ++ show state
      | y == 2 = putStr $ show state
      | y == 3 = putStrLn $ show state ++ " " ++ show x

main :: IO ()
main = do
  let board = initBoard
  roop board O

