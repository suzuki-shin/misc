-- 2012-06-24
-- 第一回

-- doubleMe x = x + x
doubleMe x = if x > 100
                  then x
                  else x * 2
-- *Main> doubleMe 30
-- 60
-- *Main> doubleMe 300
-- 300

-- http://wiki.haskell.jp/Workshop/StartHaskell/LYHGG/exercise/1
-- 1. はじめの第一歩

-- 次の計算をしなさい.
-- 18.6 ÷ 31 - 2.604 ÷ 3.1 - 0.8556 ÷ 0.31
-- *Main> 18.6 / 31 - 2.604 / 3.1 - 0.8556 / 0.31
-- -3.0

-- レンジを使って、以下のような文字列(リスト)を作ってみましょう。
-- "zvrnjfb"
-- *Main> ['z','y'..'a']
-- "zyxwvutsrqponmlkjihgfedcba"
-- *Main> ['z','v'..'a']
-- "zvrnjfb"

-- リストを切り出してみましょう。
-- let aList = [1..20]
-- というリストから
-- ++
-- head
-- tail
-- init
-- last
-- take
-- の関数を使って以下のリストを作ってみましょう。 (個々の関数すべてを使う必要はありません。また一つの関数を何度使っても良いです。)
-- [2,3,19]
-- *Main> (take 2 $ tail $ aList) ++ [last (init aList )]
-- [2,3,19]

-- 1 から 10 までのすべての整数で割り切れる数字の中で最小の値を求めよ.
-- head [x | x <- [1..], all (\n -> x `mod` n == 0) [1..10]]

-- ピタゴラスの三つ組(ピタゴラスの定理を満たす自然数)とは
-- a < b < c かつ a² + b² = c²
-- を満たす数の組である.
-- a + b + c = 1000 となるピタゴラスの三つ組が一つだけ存在する. この a, b, c を求めよ.
-- （Project Euler, Problem 9 改）
-- *Main Data.List> [(a,b,c)| a <- [1..998], b <- [a..999], let c = 1000 - a - b, a^2 + b^2 == c^2]
-- [(200,375,425)]


-- 与えらえた型から値を想像してみましょう。
-- ある日、ghciを使って遊んでいて以下のような結果が得られました。

-- Prelude> :t XXX
-- XXX :: Num t => [(t, [a] -> a)]
-- *Main Data.List> :t [(1, head)]
-- [(1, head)] :: Num t => [(t, [a] -> a)]

-- todoアプリを作ってるプロジェクト
-- https://github.com/seizans/todo/commits/master/

-- [2012-07-22 13:03]

hoge (x:_) = x ++ _
