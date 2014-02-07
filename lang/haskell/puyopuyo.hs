{-# OPTIONS_GHC -Wall #-}
import Data.Array
import Data.List

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

type Board = Array Pos Mark
type Mark = Char
type Pos = (Int,Int)

main :: IO ()
main = mapM_ print $ puyopuyo input

-- | 次の状態を返す
puyo :: [String] -> [String]
puyo = tail

-- | 状態のリストを返す
puyopuyo :: [String] -> [[String]]
puyopuyo [] = [[]]
puyopuyo x = (x : puyopuyo (puyo x))

-- | 入力[String]をArrayに変換する
toBoard :: [String] -> Board
toBoard [] = error "invalid parameter"
toBoard ss = listArray ((0,0), (height-1,width-1)) $ concat ss
  where
    width  = length (head ss)
    height = length ss

fromBoard :: Board -> [String]
fromBoard board = groupn width $ map snd pmList
  where
    pmList = assocs board
    width  = (maximum $ map (snd . fst) pmList) + 1

-- | 4つ以上同色で連なっているものの座標を返す
deletable :: Board -> [Pos]
deletable board = [(1,1),(1,2),(2,1),(3,1)]

delete :: Board -> [Pos] -> Board
delete board ps = board // [(p,' ')|p<-ps]

-- | 落下
fall :: Board -> Board
fall = toBoard . transpose . paddingFront 6 "      " . (map (paddingFrontSpace 13 . (filter (/=' ')))) . transpose . fromBoard

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