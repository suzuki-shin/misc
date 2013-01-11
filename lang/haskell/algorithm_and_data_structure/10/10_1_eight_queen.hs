{-# OPTIONS_GHC -Wall #-}
--  エイトクイーンをバックトラックで解く
import qualified Data.Map as M
import Data.Maybe (fromJust, catMaybes)
import Data.List (sortBy)

type Pos = (Int, Int)
type Board = [(Pos, Bool)]

boardSize :: Int
boardSize = 8

-- | チェスのボード
initBoard :: Board
initBoard = [((x,y), False)|x<-[0..boardSize-1],y<-[0..boardSize-1]]

-- | (x,y)にクイーンが置けるかと置いた後のボードを返す
-- >>> putQueen (0,0) [((0,0),False),((0,1),False),((1,0),False),((1,1),False)]
-- Just [((0,0),True),((0,1),False),((1,0),False),((1,1),False)]
-- >>> putQueen (1,0) [((0,0),True),((0,1),False),((1,0),True),((1,1),False)]
-- Nothing
putQueen :: Pos -> Board -> Maybe Board
putQueen p b = if check p b then Just $ insertBoard p b else Nothing
  where
    check :: Pos -> Board -> Bool
    check p' b' = not (existQueenLeft p' b') && not (existQueenLeftUp p' b') && not (existQueenLeftDown p' b')

    existQueenLeft :: Pos -> Board -> Bool
    existQueenLeft p' b' = any id $ leftLine p' b'
    existQueenLeftUp :: Pos -> Board -> Bool
    existQueenLeftUp p' b' = any id $ leftUpLine p' b'
    existQueenLeftDown :: Pos -> Board -> Bool
    existQueenLeftDown p' b' = any id $ leftDownLine p' b'

    leftLine :: Pos -> Board -> [Bool]
    leftLine (x,y) b' = map snd $ filter (\((x',y'), _) -> y' == y && x' < x) b'
    leftUpLine :: Pos -> Board -> [Bool]
    leftUpLine (x,y) b' = map snd $ filter (\((x',y'), _) -> y' == y-(x-x') && x' < x) b'
    leftDownLine :: Pos -> Board -> [Bool]
    leftDownLine (x,y) b' = map snd $ filter (\((x',y'), _) -> y' == y+(x-x') && x' < x) b'

-- | (x,y)にクイーン置いたボードを返す
-- >>> insertBoard (0,0) [((0,0),False),((0,1),False),((1,0),False),((1,1),False)]
-- [((0,0),True),((0,1),False),((1,0),False),((1,1),False)]
-- >>> insertBoard (2,2) [((0,0),False),((0,1),False),((1,0),False),((1,1),False)]
-- [((0,0),False),((0,1),False),((1,0),False),((1,1),False),((2,2),True)]
insertBoard :: Pos -> Board -> Board
insertBoard p b = M.toList $ M.insert p True $ M.fromList b

showBoard :: Board -> IO ()
showBoard b = print2DList $ pairListTo2dList b

-- | [(Pos, a)]型のデータを[[a]]型(2次元配列)のデータに変換する
-- >>> pairListTo2dList [((0,1), 1),((0,0), 2),((1,1), 3),((1,0), 4)]
-- [[2,4],[1,3]]
pairListTo2dList :: [((Int, Int), a)] -> [[a]]
pairListTo2dList board' = map (\y -> lineOf y board') $ [0..maxY board']
  where
    maxY :: [((Int, Int), a)] -> Int
    maxY b = maximum $ map (\((_,y),_) -> y) b

    lineOf :: Int -> [((Int,Int), a)] -> [a]
    lineOf y b = map snd $ sortBy compareX $ lineOf' y b

    lineOf' :: Int -> [((Int,Int), a)] -> [(Int, a)]
    lineOf' y b = map (\((x,_), e) -> (x,e)) $ filter (\((_,y'), _) -> y == y') b

    compareX :: (Int, a) -> (Int, a) -> Ordering
    compareX (x, _) (x', _) = x `compare` x'

print2DList :: [[Bool]] -> IO ()
print2DList [] = putStrLn ""
print2DList (l:ls) = do
  mapM_ (putStr . (\e -> if e then "Q " else "_ ")) l
  putStrLn ""
  print2DList ls

-- | 指定したx列にQueenが置けるかどうかを返す(置ける場合は置けるボードすべてのリスト、置けなければ[]を返す)
checkX :: Board -> Int -> [Board]
checkX b x = catMaybes  $ map (\y -> putQueen (x,y) b) [0..boardSize-1]

-- solve :: Board -> Int -> Maybe Board
-- solve b x
--   | x >= boardSize = Just b
--   | otherwise = case checkX b x of
--     [] -> Nothing
--     b':bs' -> case solve b' (x+1) of
--       Nothing -> solve 
--       Just b'' -> Just b'

-- main :: IO ()
-- main = showBoard $ fromJust $ solve initBoard 0