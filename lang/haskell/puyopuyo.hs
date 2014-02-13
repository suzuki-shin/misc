{-# OPTIONS_GHC -Wall #-}
import Data.Array
import Data.List
import Data.Tree
import Data.Maybe

input :: [String]
input =
  [ "  GYRR"
  , "RYYGYG"
  , "GYGYRR"
  , "RYGYRG"
  , "YGYRYG"
  , "GYRYRG"
  , "YGYRYR"
  , "YGYRYR"
  , "YRRGRG"
  , "RYGYGG"
  , "GRYGYR"
  , "GRYGYR"
  , "GRYGYR"
  ]

height :: Int
height = length input

width :: Int
width = length $ head input

type Board = Array Pos Mark
type Mark = Char
type Pos = (Int,Int)            -- (x,y)

main :: IO ()
-- main = mapM_ print $ puyopuyo input
main = undefined
  

-- | 次の状態を返す
puyo :: Board -> Board
puyo b = fall $ deleteMark b $ concat $ deletable b [] $ map fst $ assocs b

-- | 状態のリストを返す
puyopuyo :: Board -> [Board]
puyopuyo b = case filter (\(_,m) -> m /= ' ') $ assocs b of
  [] -> []
  _  -> (b : puyopuyo (puyo b))

-- | 入力[String]をArrayに変換する
toBoard :: [String] -> Board
toBoard [] = error "invalid parameter"
toBoard ss = listArray ((0,0), (height-1,width-1)) $ concat ss

fromBoard :: Board -> [String]
fromBoard = groupn width . map snd . assocs

-- | 4つ以上同色で連なっているものの座標を返す
deletable :: Board -> [Pos] -> [Pos] -> [[Pos]]
deletable b passed ps = filter ((>=4).length) $ map flatten $ catMaybes $ deletable' b passed ps
  where
    deletable' _ _ [] = []
    deletable' b' passed (p':ps') = (connectTree b' passed p') : (deletable' b' (p':passed) ps')

deleteMark :: Board -> [Pos] -> Board
deleteMark board ps = board // [(p,' ')|p<-ps]

-- | 落下(' 'を下に詰める)した状態を返す
fall :: Board -> Board
fall = toBoard . transpose . paddingFront width "      " . map (paddingFrontSpace height . deleteSpace) . transpose . fromBoard
  where
    deleteSpace = filter (/=' ')

-- | リストを定数個ごとに分割する
groupn :: Int -> [a] -> [[a]]
groupn _ [] = []
groupn n xs =
  let (xs1, xs2) = splitAt n xs
  in xs1 : groupn n xs2

-- | 文字列の先頭に" "を詰めて指定文字数のの文字列を返す
paddingFrontSpace :: Int -> String -> String
paddingFrontSpace n = paddingFront n ' '

-- | リストの先頭に指定した要素を詰めて、指定の数の要素数のリストを返す
paddingFront :: Int -> a ->[a] -> [a]
paddingFront n pad = reverse . take n . (++ (cycle [pad])) . reverse

-- | となり合った座標を返す
neigbors :: Pos -> [Pos]
neigbors (x,y) = [(x',y')|(x',y') <- [(x+1,y),(x-1,y),(x,y+1),(x,y-1)], 0 <= x', x' < width, 0 <= y', y' < height]

-- | 指定した座標のとなりで同色の座標リストを返す
connects :: Board -> Pos -> [Pos]
connects b p = (sameColors b p) `intersect` (neigbors p)

sameColors :: Board -> Pos -> [Pos]
sameColors b p = map fst $ filter (\(_,m) -> m == (b!p)) $ assocs b

-- | 繋がったマークのPosリストをツリーにして返す(一度通ったところは除外する)
-- >>> connectTree a [] (1,1)
-- Just (Node {rootLabel = (1,1), subForest = [Node {rootLabel = (1,2), subForest = []},Node {rootLabel = (2,1), subForest = [Node {rootLabel = (3,1), subForest = []}]}]})
connectTree :: Board -> [Pos] -> Pos -> Maybe (Tree Pos)
connectTree b passed p = if p `elem` passed
  then Nothing
  else Just $ Node p $ subTs $ connects b p
  where
    subTs :: [Pos] -> [Tree Pos]
    subTs = catMaybes . map (connectTree b (p:passed))


-- mergeT :: (Eq a) => a -> Tree a -> Tree a -> Tree a
-- mergeT targetElm (Node a subT) insertedT = if targetElm == a
--   then Node a (insertedT:subT)
--   else Node a $ map (\t -> mergeT targetElm t insertedT) subT
