{-# OPTIONS -Wall #-}
import Control.Applicative

-- | 文字列を読み込んで行頭に行番号をつけて出力するプログラム
main :: IO ()
main = lines <$> getContents >>= putStrLn . unlines . addRowNum

addRowNum :: [String] -> [String]
addRowNum ls = map (\(n,l) -> (show n) ++ ':':l) $ zip ([1..]::[Int]) ls
