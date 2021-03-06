{-# OPTIONS_GHC -Wall #-}
-- http://valvallow.blogspot.jp/2011/02/12345-12233445.html
-- Q1. (1 2 3 4 5) が与えられたとき ((1 2)(2 3)(3 4)(4 5)) を返すような関数を定義せよ
-- Q2. 1 の関数を拡張して、(0 1 2 3 4 5 6 7 8 9) と 2 が与えられたとき ((0 1)(1 2)(2 3)(3 4)(4 5)(5 6)(6 7)(7 8)(8 9)) を、(0 1 2 3 4 5 6 7 8 9) と 3 が与えられたとき ((0 1 2) (2 3 4) (4 5 6) (6 7 8) (8 9)) を、(0 1 2 3 4 5 6 7 8 9) と 4 が与えられたとき ((0 1 2 3) (3 4 5 6) (6 7 8 9)) を返すような関数を定義せよ
main :: IO ()
main = do
  let ls1 = [1..5]
      ls2 = [0..9]
  putStrLn $ show $ a1 ls1
  putStrLn $ show $ a1' ls1
  putStrLn $ show $ a2 ls2 2
  putStrLn $ show $ a2 ls2 3
  putStrLn $ show $ a2 ls2 4

-- | Q1の答えがタプルのリストで良いのなら
-- >>> a1 [1..5]
-- [(1,2),(2,3),(3,4),(4,5)]
a1 :: [Int] -> [(Int, Int)]
a1 [] = []
a1 ls = zip ls (tail ls)

-- | Q1の答えがリストのリストなら
-- >>> a1' [1..5]
-- [[1,2],[2,3],[3,4],[4,5]]
a1' :: [Int] -> [[Int]]
a1' [] = []
a1' ls = zipWith (\a  b -> [a, b]) ls (tail ls)

-- | Q2
-- >>> a2 [0..9] 2
-- [[0,1],[1,2],[2,3],[3,4],[4,5],[5,6],[6,7],[7,8],[8,9],[9]]
-- >>> a2 [0..9] 3
-- [[0,1,2],[2,3,4],[4,5,6],[6,7,8],[8,9]]
a2 :: [Int] -> Int -> [[Int]]
a2 [] _ = []
a2 _ 0 = []
a2 ls n = (take n ls) : (a2 (drop (n - 1) ls) n)
