module OX where

-- import Data.List (isInfixOf)
import qualified Data.Map as M
-- import Debug.Trace

data Mark = E | O | X deriving (Show, Eq)
type Pos = (Int, Int)
type Board = M.Map Pos Mark
data Result = Draw | Win | Lose

boardSize :: Int
boardSize = 3

initBoard :: Board
initBoard = M.fromList [((x, y) , E) | x <- [1..boardSize], y <- [1..boardSize]]

winningPatterns :: [[Pos]]
winningPatterns = [[(1,1),(1,2),(1,3)], [(2,1),(2,2),(2,3)], [(3,1),(3,2),(3,3)], -- 横
                   [(1,1),(2,1),(3,1)], [(1,2),(2,2),(3,2)], [(1,3),(2,3),(3,3)], -- 縦
                   [(1,1),(2,2),(3,3)], [(3,1),(2,2),(1,3)]] -- 斜

rev :: Mark -> Mark
rev O = X
rev X = O
rev E = E

canPut :: Board -> Int -> Pos -> Bool
canPut board boardSize pos = (isOnBoard boardSize pos) && (M.lookup pos board == Just E)

-- | Posが盤上かどうかを返す
-- >>> isOnBoard (1,5) 5
-- True
-- >>> isOnBoard (1,6) 5
-- False
-- >>> isOnBoard (6,3) 5
-- False
-- >>> isOnBoard (0,5) 5
-- False
isOnBoard :: Int -> Pos -> Bool
isOnBoard boardSize (x, y) = (x >= 1 && x <= boardSize) && (y >= 1 && y <= boardSize)

putMark :: Board -> Int -> Pos -> Mark -> Either String Board
putMark board boardSize pos mark
  | not (isOnBoard boardSize pos) = Left "Out of board."
  | canPut board boardSize pos = Right (M.insert pos mark board)
  | otherwise = Left "Can't put there."

marksPosOf :: Board -> Mark -> [Pos]
marksPosOf board mark = map (\(p, m) -> p) $ filter (\(p, m) -> m == mark) $ M.toList board

win :: Board -> [[Pos]] -> Mark -> Bool
win board winPtns mark = win' (marksPosOf board mark) winPtns
  where
    win' :: [Pos] -> [[Pos]] -> Bool
--     win' marksPos (wp:winPtns') = trace ("wp: " ++show wp ++ "\n marksPos: " ++ show marksPos) ( (wp `isIn` marksPos) || (win' marksPos winPtns') )
    win' marksPos (wp:winPtns') = (wp `isIn` marksPos) || (win' marksPos winPtns')
    win' [] _ = False
    win' _ [] = False

checkFinish :: Board -> [[Pos]] -> Mark -> Maybe Result
checkFinish board winPtns mark
  | win board winPtns mark = Just Win
  | length (marksPosOf board E) == 0 = Just Draw
  | otherwise = Nothing

-- | あるリストの全ての要素が別のリストに含まれるかを返す
-- >>> [1,2,3] `isIn` [3,1,2,4,5]
-- True
-- >>> [1,2,3] `isIn` [1,2,4,5]
-- False
-- >>> [] `isIn` [1,2,4,5]
-- True
-- >>> [] `isIn` []
-- True
-- >>> [(1,2),(2,3)] `isIn` [(3,3),(1,2),(4,5),(2,3)]
-- True
isIn :: Eq a => [a] -> [a] -> Bool
(x:xs) `isIn` ys = (x `elem` ys) && (xs `isIn` ys)
[] `isIn` _ = True

roop :: Board -> Mark -> IO ()
roop board mark = do
  renderBoard board
  board' <- turn board mark
  case board' of
    Right board1 -> do
      case checkFinish board1 winningPatterns mark of
        Just Win -> do
          putStrLn $ show mark ++ " side win!"
          renderBoard board1
        Just Draw -> do
          putStrLn "draw"
          renderBoard board1
        Nothing -> roop board1 (rev mark)
    Left err -> do
      putStrLn err
      roop board mark

-- 標準入力から座標を入力させて、正しい入力でない場合は正しくなるまで繰り返す
turn :: Board -> Mark -> IO (Either String Board)
turn board mark = do
  putStrLn $ (show mark) ++ " side turn. input x y."
  [x, y] <- inputToPos
  return $ putMark board boardSize ((read x , read y) :: (Int, Int)) mark
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

main :: IO ()
main = do
  let board = initBoard
  roop board O
