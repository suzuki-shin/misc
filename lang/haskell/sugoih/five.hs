zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' _ [] _ = []
zipWith' _ _ [] = []
zipWith' f (x:xs) (y:ys) = f x y : zipWith' f xs ys

flip' :: (a -> b -> c) -> (b -> a -> c)
flip' f = g
  where g x y = f y x

-- *Main> zip [1..5] "hello"
-- [(1,'h'),(2,'e'),(3,'l'),(4,'l'),(5,'o')]
-- *Main> flip zip [1..5] "hello"
-- [('h',1),('e',2),('l',3),('l',4),('o',5)]
-- *Main> zipWith' div [2,2..] [10,8,6,4,2]
-- [0,0,0,0,1]
-- *Main> zipWith' (flip' div) [2,2..] [10,8,6,4,2]
-- [5,4,3,2,1]

-- Prelude> map (+3) [1,4,3,1,6]
-- [4,7,6,4,9]
-- Prelude> map (++ "!") ["BIFF", "BANG", "POW"]
-- ["BIFF!","BANG!","POW!"]
-- Prelude> map (replicate 3) [3..6]
-- [[3,3,3],[4,4,4],[5,5,5],[6,6,6]]
-- Prelude> map (map (^2)) [[1,2],[3,4,5,6],[7,8]]
-- [[1,4],[9,16,25,36],[49,64]]
-- Prelude> map fst [(1,2), (3,5),(6,3),(2,6),(2,5)]
-- [1,3,6,2,2]

filter' :: (a -> Bool) -> [a] -> [a]
filter' _ [] = []
filter' p (x:xs)
  | p x = x : filter p xs
  | otherwise = filter p xs

-- *Main> filter (>3) [1,5,3,2,1,6,4,3,2,1]
-- [5,6,4]
-- *Main> filter (==3) [1,5,3,2,1,6,4,3,2,1]
-- [3,3]
-- *Main> filter even [1..10]
-- [2,4,6,8,10]
-- *Main> let notNull x = not (null x) in filter notNull [[1,2,3],[],[3,4,5],[2,2],[],[]]
-- [[1,2,3],[3,4,5],[2,2]]
-- *Main> filter (`elem` ['a'..'z']) "u LaUgH aT mE BeCaUsE I aM diFfeRent"
-- "uagameasadifeent"

-- *Main> filter (<15) (filter even [1..20])
-- [2,4,6,8,10,12,14]
-- 同じのを内包表記で書くと
-- *Main> [x | x <- [1..20], x < 15, even x]
-- [2,4,6,8,10,12,14]

-- クイックソートfilter版
quicksort :: (Ord a) => [a] -> [a]
quicksort [] = []
quicksort (x:xs) = less_eq ++ [x] ++ grater_than
  where less_eq = filter (<= x) xs
        grater_than = filter (> x) xs

-- 10万以下の数のうち3829で割り切れる最大の数を探す
largest_divisible :: Integer
largest_divisible = head (filter p [100000,99999..])
  where p x = x `mod` 3829 == 0


-- Prelude> takeWhile (/= ' ') "elephants know how to party"
-- "elephants"

--
-- 10000より小さいすべての奇数の平方数の和をもとめる
--
-- *Main> sum $ takeWhile (<10000) $ map (^2) (filter odd [1..])
-- 166650
-- *Main> sum $ takeWhile (<10000) $ map (^2) [x|x <- [1..], odd x] -- 内包表記ver1
-- 166650
-- *Main> sum $ takeWhile (<10000) $ [x^2|x <- [1..], odd x] -- 内包表記ver2
-- 166650

--
-- コラッツ列
--
-- 1. 任意の自然数から開始する
-- 2. 数が1なら終了
-- 3. 数が偶数なら、2で割る
-- 4. 数が奇数なら、3倍して1を足す
-- 5. 新しい値でこのアルゴリズムを繰り返す
-- 
-- 「1から100までの数のうち、長さ15以上のコラッツ列の開始数になるものはいくつあるか？」
--
-- まず数列を生成する関数作る
collatz :: Int -> [Int]
collatz 1 = [1]
collatz n
  | even n = n : collatz (n `div` 2)
  | odd n = n : collatz (n * 3 + 1)
-- 以下の記述だとだめだった。なんで？
--   | even n = n : collatz $ n `div` 2
--   | odd n = n : collatz $ n * 3 + 1
--
-- 次に15以上の長さになるものをもとめる
--
-- *Main> filter (\n -> length (collatz n) > 15) [1..100]
-- [7,9,14,15,18,19,22,23,25,27,28,29,30,31,33,36,37,38,39,41,43,44,45,46,47,49,50,51,54,55,56,57,58,59,60,61,62,63,65,66,67,71,72,73,74,76,77,78,79,81,82,83,86,87,88,89,90,91,92,93,94,95,97,98,99,100]
-- *Main>
-- その数
-- *Main> length $ filter (\n -> length (collatz n) > 15) [1..100]
-- 66
--
-- 本の回答
num_long_chain :: Int
num_long_chain = length (filter is_long (map collatz [1..100]))
  where is_long xs = length xs > 15
-- *Main> num_long_chain
-- 66

--
-- map関数に複数の引数を与える
--
list_of_funs = map (*) [0..]    -- 1匹数関数のリストを返す [(*0),(*1),(*2)..]
-- *Main> (list_of_funs !! 4) 5
-- 20

--
-- lambda式
--
-- *Main> map (+3) [1..5]
-- [4,5,6,7,8]
-- 下のlambdaは上のセクションと同じなのでセクションの方が良い(可読性が高い)
-- *Main> map (\x -> x + 3) [1..5]
-- [4,5,6,7,8]

-- lambda式も任意の数の引数をとることができる
-- *Main> zipWith (\a b -> (a * 30 + 3) / b) [5,4..1] [1..5]
-- [153.0,61.5,31.0,15.75,6.6]

-- lambda式もパターンマッチできる。ただし、通常の関数定義と違って一つの引数に対して複数のパターンを定義できない
-- *Main> map (\(a, b) -> a + b) [(1,2), (3,5), (6,3), (2,6), (2,5)]
-- [3,8,9,8,7]

-- flipの定義lambda版
flip' :: (a -> b -> c) -> b -> a -> c
flip' f = \x y -> f y x

-- flipの一番多い使い方は引数として関数のみ、または関数と引数1つだけを渡し、生成された関数をmapやzipWithに渡す方法
-- *Main> zipWith (flip (++)) ["love you", "love me"] ["i ", "you "]
-- ["i love you","you love me"]
-- *Main> map (flip subtract 20) [1..4]
-- [19,18,17,16]
