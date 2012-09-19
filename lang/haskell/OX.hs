module OX where

import qualified Data.Map as M

data Mark = E | O | X deriving (Show, Eq)
type Pos = (Int, Int)
type Board = M.Map Pos Mark

boardSize :: Int
boardSize = 3

initBoard :: Board
initBoard = M.fromList [((x, y) , E) | x <- [1..boardSize], y <- [1..boardSize]]

rev :: Mark -> Mark
rev O = X
rev X = O
rev E = E

canPut :: Board -> Pos -> Bool
canPut board pos = (isOnBoard pos) && (M.lookup pos board == Just E)

isOnBoard :: Pos -> Bool
isOnBoard (x, y) = (x >= 1 && x <= boardSize) && (y >= 1 && y <= boardSize)

putMark :: Board -> Pos -> Mark -> Either String Board
putMark board pos mark
  | isOnBoard pos = if canPut board pos
                    then Right (M.insert pos mark board)
                    else Left "Can't put there."
  | otherwise = Left "Out of board."

roop :: Board -> Mark -> IO b
roop board mark = do
  renderBoard board
  board' <- tern board mark
  case board' of
    Right board1 -> roop board1 (rev mark)
    Left err -> do
      print err
      roop board mark

-- 標準入力から座標を入力させて、正しい入力でない場合は正しくなるまで繰り返す
tern :: Board -> Mark -> IO (Either String Board)
tern board mark = do
  [x, y] <- inputToPos
  return $ putMark board ((read x , read y) :: (Int, Int)) mark
    where
      inputToPos = do
        l <- getLine
        if length (words l) == 2
          then return $ words l
          else inputToPos

renderBoard :: M.Map Pos Mark -> IO ()
renderBoard board = do
  putStrLn "123\n---"
  mapM_ renderCol $ M.toList board
  putStrLn "---\n"
  where
    renderCol :: (Pos, Mark) -> IO ()
    renderCol ((x,y), mark)
      | y == 3 = putStrLn $ show mark ++ " " ++ show x
      | otherwise = putStr $ show mark

main :: IO ()
main = do
  let board = initBoard
  roop board O

