5.1 数を言葉に変換する

まず0 < n < 100の場合を考える

> convert2 :: Int -> String
> convert2 = combine2 . digit2

> digit2 :: Int -> (Int, Int)
> digit2 n = (n `div` 10, n `mod` 10)

*Main> digit2 10
(1,0)
*Main> digit2 13
(1,3)
*Main> digit2 34
(3,4)
*Main> digit2 98
(9,8)
*Main>

> combine2 :: (Int, Int) -> String
> combine2 (0, u)
>   | u >= 1 = units!!(u-1) -- combine2 (0, u + 1) = units!!u -- これのu + 1はhaskell的にはだめだった
>   | otherwise = error "error"
> combine2 (1, u) = teens!!u
> combine2 (t, 0)
>   | t >= 2 = tens!!(t-2)
>   | otherwise = error "error"
> combine2 (t, u)
>   | t >= 2 = tens!!(t-2) ++ "-" ++ units!!(u-1)
>   | otherwise = error "error"

> units :: [String]
> units = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
> teens :: [String]
> teens = ["ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen"]
> tens :: [String]
> tens =  ["twenty", "thirty", "forty", "fifty","sixty", "seventy", "eighty", "ninety"]

0 < n < 1000を考える

> convert3 :: Int -> String
> convert3 = combine3 . digit3

> digit3 :: Int -> (Int, Int)
> digit3 n = (n`div`100, n`mod`100)

nを百の位hと百以下の値tに分けて考える
tはconvert2で処理する

> combine3 :: (Int, Int) -> String
> combine3 (0,t)
>   | t >= 1 = convert2 t
>   | otherwise = error "error"
> combine3 (h,0)
>   | h >= 1 = units!!(h-1) ++ " hundred"
>   | otherwise = error "error"
> combine3 (h,t)
>   | h >= 1 && t >= 1 = units!!(h-1) ++ " hundred and " ++ convert2 t
>   | otherwise = error "error"

0 < n < 1000000を考える

> convert6 :: Int -> String
> convert6 = combine6 . digit6

> digit6 :: Int -> (Int, Int)
> digit6 n = (n`div`1000, n`mod`1000)

nを千の位hと千以下の値tに分けて考える
tはconvert3で処理する

> combine6 :: (Int, Int) -> String
> combine6 (0,h)
>   | h >= 1 = convert3 h
>   | otherwise = error "error"
> combine6 (m,0)
>   | m >= 1 = convert3 m ++ " thousand"
>   | otherwise = error "error"
> combine6 (m,h)
>   | m >= 1 && h >= 1 = convert3 m ++ " thousand" ++ link h ++ convert3 h
>   | otherwise = error "error"

> link :: Int -> String
> link h = if h < 100 then " and " else " "

練習問題

5.1.1

> convert6' :: Int -> String
> convert6' = combine6' . digit6
> combine6' :: (Int, Int) -> String
> combine6' (0,h)
>   | h >= 1 = convert3 h ++ "."
>   | otherwise = error "error"
> combine6' (m,0)
>   | m >= 1 = convert3 m ++ " thousand."
>   | otherwise = error "error"
> combine6' (m,h)
>   | m >= 1 && h >= 1 = convert3 m ++ " thousand" ++ link h ++ convert3 h ++ "."
>   | otherwise = error "error"

5.1.2

0 < n < 1000000000

一億が"one hundred million"
十億が"one billion"

> convert10 :: Int -> String
> convert10 = combine10 . digit10

10 ** 6 でmillionだから
nを10**6の位hと10**6以下の値mに分けて考える
mはconvert6で処理する

> digit10 :: Int -> (Int, Int)
> digit10 n = (n`div`1000000, n`mod`1000000)

> combine10 :: (Int, Int) -> String
> combine10 (0,a)
>   | a >= 1 = convert6 a
>   | otherwise = error "error"
> combine10 (m,0)
>   | m >= 1 = convert3 m ++ " million"
>   | otherwise = error "error"
> combine10 (m,a)
>   | m >= 1 && a >= 1 = convert3 m ++ " million and " ++ convert6 a
>   | otherwise = error "error"

5.1.3

0や負の数を扱えるようにするにはどうすればよいか？

> convert10' :: Int -> String
> convert10' n
>   | n >  0 = convert10 n
>   | n == 0 = "zero"
>   | n <  0 = "minus " ++ convert10' (-n)

5.1.4

はまあいいか

5.1.5

convertの逆を行う関数

