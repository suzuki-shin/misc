{-# OPTIONS_GHC -Wall -XRankNTypes #-}
import Control.Monad.State
import Control.Applicative ((<$>),(<*>))
import Data.List (isInfixOf, intersect)
import Data.List.Split (splitOn)
import Data.Array (Array, listArray, assocs, (//), (!))
import Data.Maybe (fromJust)
import Data.Set (isSubsetOf, fromList)

data Mark = E | X | O deriving (Eq)
instance Show Mark where
  show E = "_"
  show O = "O"
  show X = "X"

type Pos = (Int,Int)
type Board = Array Pos Mark
data Result = Lose | Draw | Win deriving Show
data Player = P1 | P2
data GameState = Finished Result | InPlay deriving Show
type GameData = (GameState, Mark, Board)

main :: IO ()
main = do
  putStrLn "start"
  runStateT play $ (InPlay, O, emptyBoard)
  putStrLn "finish"

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
putMark :: Mark -> Pos -> State Board ()
putMark mark pos = do
  board <- get
  put $ board // [(pos,mark)]

putMark2 :: Mark -> Pos -> StateT Board Maybe ()
putMark2 mark pos = do
  board <- get
  if canPut mark pos board
    then put $ board // [(pos,mark)]
    else StateT $ const Nothing
-}

canPut :: Mark -> Pos -> Board -> Bool
canPut mark pos board = (pos `isOn` board) && (pos `isEmpty` board)

isOn :: Pos -> Board -> Bool
isOn (y,x) board = (y <= maxY) && (x <= maxX)
  where
    (maxY, maxX) = bound board

bound :: Board -> (Int, Int)
bound _ = (3,3)

isEmpty :: Pos -> Board -> Bool
isEmpty pos board = (board ! pos) == E

play :: StateT GameData IO ()
play = do
  (st,m,_) <- get
  case st of
    Finished res -> liftIO $ putStrLn $ "game over. player of " ++ show m ++ " " ++ show res
    InPlay       -> play'
  where
    play' :: StateT GameData IO ()
    play' = do
      (st, mark, board) <- get
      liftIO $ putStrLn $ show mark ++ " side turn."
      liftIO $ putStrLn "input x. 0~2"
      x <- read <$> liftIO getLine
      liftIO $ putStrLn "input y. 0~2"
      y <- read <$> liftIO getLine
      if canPut mark (y,x) board
        then do
          put $ (st, mark, board // [((y,x), mark)])
          judge
          (st',m',b') <- get
          put $ (st', next m', b')
        else liftIO $ putStrLn "can't put there."
      play

judge :: StateT GameData IO ()
judge = do
  (_,m,b) <- get
  liftIO $ print m
  printBoard
  if win winningPatterns (positionsOf b m)
    then do
      liftIO $ print "win;;;;"
      put $ (Finished Win,m,b)
    else do
      liftIO $ print "continue;;;;"
      put $ (InPlay,m,b)
  return ()
  where
    win :: [[Pos]] -> [Pos] -> Bool
    win winningPtns ps = any id $ map (`isOccupied` ps) winningPtns

-- | targetPsの要素をすべてpsが含んでいるか
isOccupied :: [Pos] -> [Pos] -> Bool
isOccupied targetPs ps = targetPs' `isSubsetOf` ps'
  where
    ps' = fromList ps
    targetPs' = fromList targetPs

winningPatterns :: [[Pos]]
winningPatterns = [
  [(0,0),(0,1),(0,2)]
 ,[(1,0),(1,1),(1,2)]
 ,[(2,0),(2,1),(2,2)]
 ,[(0,0),(1,0),(2,0)]
 ,[(0,1),(1,1),(2,1)]
 ,[(0,2),(1,2),(2,2)]
 ,[(0,0),(1,1),(2,2)]
 ,[(0,2),(1,1),(2,0)]
 ]

positionsOf :: Board -> Mark -> [Pos]
positionsOf b m = map fst $ filter (\(_,m') -> m == m') $ assocs b

next :: Mark -> Mark
next O = X
next X = O

mark :: Player -> Mark
mark P1 = O
mark P2 = X

fromBoard :: forall a. Array Pos a -> [[a]]
fromBoard = groupn 3 . map snd . assocs

printBoard :: StateT GameData IO ()
printBoard = do
  (_,_,b) <- get
  liftIO $ mapM_ print $ fromBoard b
  liftIO $ putStrLn ""

-- | リストを定数個ごとに分割する
groupn :: Int -> [a] -> [[a]]
groupn _ [] = []
groupn n xs =
  let (xs1, xs2) = splitAt n xs
  in xs1 : groupn n xs2
