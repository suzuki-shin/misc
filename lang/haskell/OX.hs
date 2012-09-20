module OX where

import Data.List (isInfixOf)
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
  | not (isOnBoard pos) = Left "Out of board."
  | canPut board pos = Right (M.insert pos mark board)
  | otherwise = Left "Can't put there."

roop :: Board -> Mark -> IO ()
roop board mark = do
  renderBoard board
  board' <- turn board mark
  case board' of
    Right board1 -> do
      if win board1 winningPatterns mark
         then putStrLn $ show mark ++ " side win!"
         else roop board1 (rev mark)
    Left err -> do
      putStrLn err
      roop board mark

-- 標準入力から座標を入力させて、正しい入力でない場合は正しくなるまで繰り返す
turn :: Board -> Mark -> IO (Either String Board)
turn board mark = do
  putStrLn $ (show mark) ++ " side turn. input x y."
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
  putStrLn "123\n   "
  mapM_ renderCol $ M.toList board
  putStrLn "   \n"
    where
      renderCol :: (Pos, Mark) -> IO ()
      renderCol ((x,y), mark)
        | y == 3 = putStrLn $ show mark ++ " " ++ show x
        | otherwise = putStr $ show mark

winningPatterns :: [[Pos]]
winningPatterns = [[(1,1),(1,2),(1,3)], [(2,1),(2,2),(2,3)], [(3,1),(3,2),(3,3)], -- 横
                   [(1,1),(2,1),(3,1)], [(1,2),(2,2),(3,2)], [(1,3),(2,3),(3,3)], -- 縦
                   [(1,1),(2,2),(3,3)], [(3,1),(2,2),(1,3)]] -- 斜

marksPosOf :: Board -> Mark -> [Pos]
marksPosOf board mark = map (\(p, m) -> p) $ filter (\(p, m) -> m == mark) $ M.toList board

win :: Board -> [[Pos]] -> Mark -> Bool
win board winPtns mark = win' (marksPosOf board mark) winPtns
  where
    win' :: [Pos] -> [[Pos]] -> Bool
    win' marksPos (p:winPtns') = (p `isInfixOf` marksPos) || (win' marksPos winPtns')
    win' [] _ = False
    win' _ [] = False

main :: IO ()
main = do
  let board = initBoard
  roop board O

