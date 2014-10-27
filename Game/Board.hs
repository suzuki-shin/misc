module Game.Board where

import Data.Array (Array, listArray, (//), elems, bounds)

data Player = P1 | P2 deriving (Show, Eq)
type PieceClass = String        -- 駒の種類
data Piece = Piece { player :: Player, pieceClass :: PieceClass } deriving (Show, Eq)
type Pos = (Int,Int)
data PosState = Empty | Occupied Piece deriving (Show, Eq)
type Board = Array Pos PosState

draw :: PosState -> String
draw Empty = " E"
draw (Occupied (Piece P1 pc)) = '^' : pc
draw (Occupied (Piece P2 pc)) = 'v' : pc

-- | 2次元リストを(座標, 値)のarrayに変換(array版)
-- >>> toArray [["0","0","0","0","0","0"],["0","1","1","0","0","0"],["0","1","0","0","0","0"],["0","0","0","0","1","0"],["0","0","0","1","0","0"],["0","0","0","0","0","0"]]
-- array ((0,0),(5,5)) [((0,0),"0"),((0,1),"0"),((0,2),"0"),((0,3),"0"),((0,4),"0"),((0,5),"0"),((1,0),"0"),((1,1),"1"),((1,2),"1"),((1,3),"0"),((1,4),"0"),((1,5),"0"),((2,0),"0"),((2,1),"1"),((2,2),"0"),((2,3),"0"),((2,4),"0"),((2,5),"0"),((3,0),"0"),((3,1),"0"),((3,2),"0"),((3,3),"0"),((3,4),"1"),((3,5),"0"),((4,0),"0"),((4,1),"0"),((4,2),"0"),((4,3),"1"),((4,4),"0"),((4,5),"0"),((5,0),"0"),((5,1),"0"),((5,2),"0"),((5,3),"0"),((5,4),"0"),((5,5),"0")]
toArray :: Show a => [[a]] -> Array (Int,Int) a
toArray ss = listArray ((0,0),(width - 1 ,height - 1)) $ concat ss
  where
    height = length ss
    width = length $ head ss


-- | 何も乗っていないボードを作る
-- >>> emptyBoard 3 2
-- array ((0,0),(1,2)) [((0,0),Empty),((0,1),Empty),((0,2),Empty),((1,0),Empty),((1,1),Empty),((1,2),Empty)]
emptyBoard :: Int -> Int -> Board
emptyBoard x y = toArray $ replicate x $ replicate y Empty


-- | 駒を配置する
-- >>> deployPiece 2 2 [((0,0), Occupied (Piece P1 "A")),((1,1), Occupied (Piece P1 "A")),((0,1), Occupied (Piece P2 "B")),((1,0), Occupied (Piece P2 "B"))]
-- array ((0,0),(1,1)) [((0,0),Occupied (Piece {player = P1, pieceClass = "A"})),((0,1),Occupied (Piece {player = P2, pieceClass = "B"})),((1,0),Occupied (Piece {player = P2, pieceClass = "B"})),((1,1),Occupied (Piece {player = P1, pieceClass = "A"}))]
deployPiece :: Int -> Int -> [(Pos, PosState)] -> Board
deployPiece x y ps = emptyBoard x y // ps


-- | リストを定数個ごとに分割する
groupn :: Int -> [a] -> [[a]]
groupn _ [] = []
groupn n xs = let (xs1, xs2) = splitAt n xs
               in xs1 : groupn n xs2


printBoard :: Board -> IO ()
printBoard b = do
  let a = groupn (width b) $ map draw $ elems b
  mapM_ (putStrLn . concat) a
  where
    width :: Board -> Int
    width b_ = (snd . snd . bounds) b_ + 1
