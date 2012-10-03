{-# OPTIONS -Wall #-}
module Board (
    Pos
  , Board
  , BoardInfo (BoardInfo, getSize, getBoard)
  , Mark (E, O, X)
  , isOnBoard
  , emptyBoard
  , roop
  , marksPosOf
  , markOf
  , rev
  , renderBoard -- DEBUG
  ) where

import qualified Data.Map as M

data Mark = E | O | X deriving (Eq)
instance Show Mark where
  show E = "_"
  show O = "O"
  show X = "X"

type Pos = (Int, Int)
type Board = M.Map Pos Mark
data BoardInfo = BoardInfo {getSize :: Int, getBoard :: Board} deriving (Show, Eq)
data Result =  Lose | Draw | Win

emptyBoard :: Int -> BoardInfo
emptyBoard boardSize = BoardInfo boardSize $ M.fromList [((x, y) , E) | x <- [1..boardSize], y <- [1..boardSize]]

roop :: BoardInfo
        -> (BoardInfo -> Pos -> Mark -> BoardInfo)
        -> (BoardInfo -> Pos -> Mark -> Bool)
        -> (Board -> Mark -> Bool)
        -> (Board -> Mark -> Bool)
        -> (Board -> Mark -> Bool)
        -> Mark
        -> IO ()
roop boardInfo action canPut checkWin checkDraw checkLose mark = do
  renderBoard boardInfo
  boardInfo' <- turn boardInfo action canPut mark
  case checkFinish (getBoard boardInfo') checkWin checkDraw checkLose mark of
    Just Win -> do
      renderBoard boardInfo'
      putStrLn $ show mark ++ " side win!"
    Just Draw -> do
      renderBoard boardInfo'
      putStrLn "draw"
    Just Lose -> do
      renderBoard boardInfo'
      putStrLn $ show mark ++ " side lose!"
    Nothing -> roop boardInfo' action canPut checkWin checkDraw checkLose (rev mark)


-- | Posが盤上かどうかを返す
-- >>> isOnBoard 5 (1,5)
-- True
-- >>> isOnBoard 5 (1,6)
-- False
-- >>> isOnBoard 5 (6,3)
-- False
-- >>> isOnBoard 5 (0,5)
-- False
isOnBoard :: Int -> Pos -> Bool
isOnBoard size (x, y) = (x >= 1 && x <= size) && (y >= 1 && y <= size)

-- | boardInfoとPosとMarkをとりPos位置にMarkが置けるかをチェックして、おけるならばおいたboardInfoをRight boardInfoで返し、置けないならばLeft errを返す
-- >>> let bi = BoardInfo {getSize = 2, getBoard = M.fromList [((1,1),O),((1,2),X),((2,1),E),((2,2),E)]}
-- >>> let canPut boardInfo pos _ = (isOnBoard (getSize boardInfo) pos) && ((markOf (getBoard boardInfo) pos) == Just E)
-- >>> putMark bi canPut (2,1) O
-- Right (BoardInfo {getSize = 2, getBoard = fromList [((1,1),O),((1,2),X),((2,1),O),((2,2),_)]})
-- >>> putMark bi canPut (1,3) O
-- Left "Can't put there."
-- >>> putMark bi canPut (1,1) O
-- Left "Can't put there."
putMark :: BoardInfo -> (BoardInfo -> Pos -> Mark -> Bool) -> Pos -> Mark
           -> Either String BoardInfo
putMark boardInfo canPut pos mark
  | canPut boardInfo pos mark = Right $ BoardInfo (getSize boardInfo) (M.insert pos mark (getBoard boardInfo))
  | otherwise = Left "Can't put there."

-- | Markを指定して、盤上のそのMarkすべての位置を返す
-- >>> let b = M.fromList [((1,1),O),((1,2),X),((1,3),O),((2,1),E),((2,2),E),((2,3),O),((3,1),X),((3,2),E),((3,3),E)] :: Board
-- >>> marksPosOf b O
-- [(1,1),(1,3),(2,3)]
-- >>> marksPosOf b X
-- [(1,2),(3,1)]
-- >>> marksPosOf b E
-- [(2,1),(2,2),(3,2),(3,3)]
marksPosOf :: Board -> Mark -> [Pos]
marksPosOf board mark = map fst $ filter (\(_, m) -> m == mark) $ M.toList board

-- | 位置を指定して、その位置にあるMarkをMaybe Markで返す
markOf :: Board -> Pos -> Maybe Mark
markOf board pos = M.lookup pos board

-- | 標準入力から座標を入力させて(正しい入力でない場合は正しくなるまで繰り返す)、その座標にマークをおき、何らかの処理をして、
turn :: BoardInfo
        -> (BoardInfo -> Pos -> Mark -> BoardInfo)
        -> (BoardInfo -> Pos -> Mark -> Bool)
        -> Mark
        -> IO BoardInfo
turn boardInfo action canPut mark = do
  putStrLn $ (show mark) ++ " side turn. input x y."
  pos <- inputToPos
  case putMark boardInfo canPut pos mark of
    Right boardInfo' -> return $ action boardInfo' pos mark
    Left err -> do
      putStrLn err
      turn boardInfo action canPut mark
    where
      inputToPos :: IO (Int, Int)
      inputToPos = do
        l <- getLine
        if length (words l) == 2
          then return $ list2ToTuple2 $ map read $ words l
          else inputToPos
      list2ToTuple2 :: [Int] -> (Int, Int)
      list2ToTuple2 [n1, n2] = (n1, n2)
      list2ToTuple2 _ = error "list2ToTuple2 args error"

-- | ボードを描画する
renderBoard :: BoardInfo -> IO ()
renderBoard (BoardInfo size board) = do
--   putStrLn "123\n   "
  mapM_ (putStr . show . (\n -> if n >= 10 then n `mod` 10 else n)) [1..size]
  putStrLn "\n"
  mapM_ renderCol $ M.toList board
  putStrLn "\n"
    where
      renderCol :: (Pos, Mark) -> IO ()
      renderCol ((x,y), mark)
        | y == size = putStrLn $ show mark ++ " " ++ show x
        | otherwise = putStr $ show mark

rev :: Mark -> Mark
rev O = X
rev X = O
rev E = E

-- | ゲームが終了条件を満たしているかをチェックし、満たしていればJust結果を、満たしていなければNothingを返す
checkFinish :: Board
               -> (Board -> Mark -> Bool)
               -> (Board -> Mark -> Bool)
               -> (Board -> Mark -> Bool)
               -> Mark
               -> Maybe Result
checkFinish board win draw lose mark
  | win board mark = Just Win
  | draw board mark = Just Draw
  | lose board mark = Just Lose
  | otherwise = Nothing
