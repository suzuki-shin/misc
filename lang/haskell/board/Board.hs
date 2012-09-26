module Board (
    Pos
  , Mark (E, O, X)
  , emptyBoard
  , roop
  ) where

import qualified Data.Map as M
import MyList
-- import Debug.Trace

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

roop :: BoardInfo -> [[Pos]] -> Mark -> IO ()
roop boardInfo winPtns mark = do
  renderBoard boardInfo
  boardInfo' <- turn boardInfo mark
  case boardInfo' of
    Right boardInfo1 -> do
      case checkFinish (getBoard boardInfo1) winPtns mark of
        Just Win -> do
          renderBoard boardInfo1
          putStrLn $ show mark ++ " side win!"
        Just Draw -> do
          renderBoard boardInfo1
          putStrLn "draw"
        Nothing -> roop boardInfo1 winPtns (rev mark)
    Left err -> do
      putStrLn err
      roop boardInfo winPtns mark


-- | 指定したPosにMarkを置くことができるかどうかを返す
canPut :: BoardInfo -> Pos -> Bool
canPut boardInfo pos = (isOnBoard (getSize boardInfo) pos) && ((markOf (getBoard boardInfo) pos) == Just E)

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
-- >>> putMark bi (2,1) O
-- Right (BoardInfo {getSize = 2, getBoard = fromList [((1,1),O),((1,2),X),((2,1),O),((2,2),E)]})
-- >>> putMark bi (1,3) O
-- Left "Can't put there."
-- >>> putMark bi (1,1) O
-- Left "Can't put there."
putMark :: BoardInfo -> Pos -> Mark -> Either String BoardInfo
putMark boardInfo pos mark
  | canPut boardInfo pos = Right $ BoardInfo (getSize boardInfo) (M.insert pos mark (getBoard boardInfo))
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
marksPosOf board mark = map (\(p, m) -> p) $ filter (\(p, m) -> m == mark) $ M.toList board

-- | 位置を指定して、その位置にあるMarkをMaybe Markで返す
markOf :: Board -> Pos -> Maybe Mark
markOf board pos = M.lookup pos board

-- | 標準入力から座標を入力させて、正しい入力でない場合は正しくなるまで繰り返す
turn :: BoardInfo -> Mark -> IO (Either String BoardInfo)
turn boardInfo mark = do
  putStrLn $ (show mark) ++ " side turn. input x y."
  [x, y] <- inputToPos
  return $ putMark boardInfo ((read x , read y) :: (Int, Int)) mark
    where
      inputToPos = do
        l <- getLine
        if length (words l) == 2
          then return $ words l
          else inputToPos

-- | ボードを描画する
renderBoard :: BoardInfo -> IO ()
renderBoard (BoardInfo size board) = do
--   putStrLn "123\n   "
  mapM_ (putStr . show) [1..size]
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


-- | 指定したMarkが勝利条件を満たしているかを返す
win :: Board -> [[Pos]] -> Mark -> Bool
win board winPtns mark = win' (marksPosOf board mark) winPtns
  where
    win' :: [Pos] -> [[Pos]] -> Bool
--     win' marksPos (wp:winPtns') = trace ("wp: " ++show wp ++ "\n marksPos: " ++ show marksPos) ( (wp `isIn` marksPos) || (win' marksPos winPtns') )
    win' marksPos (wp:winPtns') = (wp `isIn` marksPos) || (win' marksPos winPtns')
    win' [] _ = False
    win' _ [] = False

-- | ゲームが終了条件を満たしているかをチェックし、満たしていればJust結果を、満たしていなければNothingを返す
checkFinish :: Board -> [[Pos]] -> Mark -> Maybe Result
checkFinish board winPtns mark
  | win board winPtns mark = Just Win
  | length (marksPosOf board E) == 0 = Just Draw
  | otherwise = Nothing
