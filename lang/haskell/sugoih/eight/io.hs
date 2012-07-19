-- IOアクションはmainという名前をつけてプログラムを起動すると実行される
-- main = do
--   putStrLn "Hello, what's your name?"
--   name <- getLine
--   putStrLn $ "Zis is your future: " ++ tellFortune name

-- tellFortune :: String -> String
-- tellFortune "" = "nantekottai!!"
-- tellFortune name = name ++ " become a hero!"

{-
-- IOアクションの中でletを使う
import Data.Char

main = do
  putStrLn "What's your first name?"
  firstName <- getLine
  putStrLn "What's your last name?"
  lastName <- getLine
  let bigFirstName = map toUpper firstName
      bigLastName = map toUpper lastName
  putStrLn $ "hey " ++ bigFirstName ++ " " ++ bigLastName ++ ", how are you?"
-}

{-
-- 逆順に表示する
main = do
  line <- getLine
  if null line
    then return ()
    else do
        putStrLn $ reverseWords line
        main

reverseWords :: String -> String
reverseWords = unwords . map reverse . words
-}

-- when
-- whenはBoolとIOアクションを受け取り、Boolの値がTrueの場合には渡されたIOと同じものを返す。
-- Falseの場合には何もしないreturn ()を返す
{-
import Control.Monad

main = do
  input <- getLine
  when (input == "SWORDFISH") $ do
    putStrLn input
-}
{-
-- whenを使わない場合
main = do
  input <- getLine
  if (input == "SWORDFISH")
    then putStrLn input
    else return
-}

-- seqence
{-
main = do
  a <- getLine
  b <- getLine
  c <- getLine
  print [a,b,c]
-}
-- seqenceを使って上と同じ処理を書くと
{-
main = do
  rs <- seqence [getLine, getLine, getLine]
  print rs
-}

-- sequenceを使った良くあるパターン。リストに対してprintやputStrLnのような関数をmapするとき
-- Prelude> sequence $ map print [1..5]
-- 1
-- 2
-- 3
-- 4
-- 5
-- [(),(),(),(),()]

-- mapM
-- 「リストに対してIOアクションを返す関数をマップし、それからシーケンスにする」
-- という操作は頻出なので、mapMとmapM_がある。mapM_は結果を捨てる
{-
Prelude> mapM print [1,2,3]
1
2
3
[(),(),()]
Prelude> mapM_ print [1,2,3]
1
2
3
Prelude>
-}

-- forever
-- IOアクションを受け取り、そのIOアクションを永遠に繰り返すIOアクションを返す
import Control.Monad
import Data.Char

main = forever $ do
  putStr "Give me some input: "
  l <- getLine
  putStrLn $ map toUpper l

-- forM
