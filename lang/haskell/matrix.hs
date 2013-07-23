{-# OPTIONS -Wall #-}
import Control.Applicative
import Data.List

data State = O | X deriving Show

main :: IO ()
main = do
  items <- lines <$> getContents
  printHeader items
  printMatrix $ matrix items

-- | 入力項目のリストに対するO、Xのマトリクスを返す
-- >>> matrix ["hoge","fuga","foo"]
-- [[O,O,O],[O,O,X],[O,X,O],[O,X,X],[X,O,O],[X,O,X],[X,X,O],[X,X,X]]
-- >>> matrix []
-- [[]]
matrix :: [String] -> [[State]]
matrix = mapM (\_ -> [O, X])

-- | Matrixデータを表形式で出力する
printMatrix :: [[State]] -> IO ()
printMatrix (col:cols) = do
  putStr $ listToTsv $ map show col
  putStrLn ""
  printMatrix cols
printMatrix [] = return ()

-- | ヘッダを出力する
printHeader :: [String] -> IO ()
printHeader items = do
  putStr $ listToTsv items
  putStrLn ""

-- | 文字列のリストをタブ区切りの文字列にする
-- >>> listToTsv ["hoge","fuga","bar"]
-- "hoge\tfuga\tbar"
listToTsv :: [String] -> String
listToTsv = intercalate "\t"
