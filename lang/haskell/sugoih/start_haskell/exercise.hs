{-# OPTIONS -Wall #-}
import Data.Char

-- http://wiki.haskell.jp/Workshop/StartHaskell/LYHGG/exercise/3
myNot :: Bool -> Bool
myNot True = False
myNot False = True

myAnd :: Bool -> Bool -> Bool
myAnd True True = True
myAnd _ _ = False

myOr  :: Bool -> Bool -> Bool
myOr False False = False
myOr _ _ = True

myXor :: Bool -> Bool -> Bool
myXor True False = True
myXor False True = True
myXor _ _ = False

-- うるう年

-- うるう年を判定する関数を書いてみよう。

-- 西暦年が4で割り切れる年はうるう年
-- ただし、西暦年が100で割り切れる年はうるう年でない
-- ただし、西暦年が400で割り切れる年はうるう年
-- isLeap :: Int -> Bool
-- 実行例

-- ghci> isLeap 1999
-- False
-- ghci> isLeap 2000
-- True

isLeap :: Int -> Bool
isLeap year | year `mod` 400 == 0 = True
            | year `mod` 100 == 0 = False
            | year `mod` 4 == 0 = True
            | otherwise = False

-- 次の関数からcaseとifを取り除いてみましょう。
-- analysisLine :: String -> String
-- analysisLine s = 
--   case s of [] -> "empty"
--             [_] -> "a character"
--             s' -> if last s' == '.' 
--                   then "a sentence"
--                   else if ' ' `elem` s' 
--                        then "some words"
--                        else "a word"
-- ヒント: パターンマッチとガードを使います。
analysisLine :: String -> String
analysisLine [] = "empty"
analysisLine [_] = "a character"
analysisLine s' |last s' == '.' = "a sentence"
                | ' ' `elem` s' = "some words"
                | otherwise = "a word"


-- シーザー暗号
-- 与えられた文字列をシーザー暗号で暗号化する関数を作成しよう。
-- caesar :: Int        -- 何文字右へずらすか
--        -> String     -- 暗号化する文字列
--        -> String     -- 暗号化された文字列
-- a～z の文字は、指定された数だけ右へずらす、ただし z の次は a に戻る
-- A～Z の文字は、指定された数だけ右へずらす、ただし Z の次は A に戻る
-- それ以外の文字や記号や空白は、ずらさない
-- 実行例
-- ghci> caesar 1 "Hello, world!"
-- "Ifnmp, xpsme"
-- ghci> caesar 10 "(^o^) <`v`> ['-'] {~<~} |T_T|"
-- "(^y^) <`f`> ['-'] {~<~} |D_D|"
-- 上の関数を使って、以下のシーザー暗号を解読できますか。
-- Par Yngvmbhgte Ikhzktffbgz Ftmmxkl
caesar :: Int -> String -> String
caesar _ [] = []
caesar n (x:xs)
       | x == 'z' = ('a' : caesar n xs)
       | x == 'Z' = ('A' : caesar n xs)
       | x `elem` ['A'..'Y'] = ((chr (ord x + n)) : caesar n xs)
       | x `elem` ['a'..'y'] = ((chr (ord x + n)) : caesar n xs)
       | otherwise = (x : caesar n xs)


-- http://wiki.haskell.jp/Workshop/StartHaskell/LYHGG/exercise/4

-- リストの長さ
-- リストの長さを返す関数を、再帰を使って自分で書いてみよう。
myLength :: [a] -> Int
myLength [] = 0
myLength (_:xs) = 1 + myLength xs

-- リストの要素を全部足す関数と、全部かける関数を、再帰を使って書いてみよう。
-- mySum      :: [Int] -> Int
-- myProduct  :: [Int] -> Int
-- 実行例
-- ghci> mySum [1,2,3,4]
-- 10
-- ghci> myProduct [1,2,3,4]
-- 24
mySum :: [Int] -> Int
mySum [] = 0
mySum (x:xs) = x + mySum xs

myProduct  :: [Int] -> Int
myProduct [] = 1
myProduct (x:xs) = x * myProduct xs

-- 偶数と奇数にわける
-- 整数のリストを受け取って、奇数だけのリストと偶数だけのリストに分ける関数を、再帰を使って書いてみよう。
-- oddEven :: [Int] -> ([Int],[Int])
-- 実行例
-- ghci> oddEven [1,4,5,6,7,10,11]
-- ([1,5,7,11], [4,6,10])
oddEven :: [Int] -> ([Int],[Int])
oddEven ns = ((filter odd ns), (filter even ns)) -- 再帰じゃない版
