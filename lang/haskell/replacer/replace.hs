{-|
| input.txtの中身をreplaceWords.txtのwordのペアリスト(tsvファイル)のルールで置き換える
|-}

import Control.Applicative
import Data.List
import Data.List.Split

type StrPairs = [(String, String)]

main :: IO ()
main = do
  c <- readFile "input.txt"
  r <- tsvToStrPairs <$> readFile "replaceWords.txt"
  writeFile "output.txt" $ strRep r c
--   putStrLn $ strRep r c

strRep [] s = s
strRep (m:ms) s = strRep ms (replace (fst m) (snd m) s)

replace :: String -> String -> String -> String
replace s d  = intercalate d . splitOn s

tsvToStrPairs :: String -> StrPairs
tsvToStrPairs input = map (\(a:b:c) -> (a,b)) $ map (splitOn "\t") $ lines input
