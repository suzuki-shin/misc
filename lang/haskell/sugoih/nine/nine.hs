import System.IO
import Data.Char

main = do
  contents <- readFile "baabaa.txt"
  writeFile "baabaacaps.txt" (map toUpper contents)

--   withFile "baabaa.txt" ReadMode $ \handle -> do
--     contents <- hGetContents handle
--     putStr contents
  
--   handle <- openFile "baabaa.txt" ReadMode
--   contents <- hGetContents handle
--   putStr contents
--   hClose handle

-- main = interact respond_palindromes
-- main = interact shortLinesOnly

shortLinesOnly :: String -> String
shortLinesOnly = unlines . filter (\line -> length line < 10) . lines

respond_palindromes :: String -> String
respond_palindromes
  = unlines .
    map (\xs -> if is_pal xs then "palindrome" else "not a palindrome") .
    lines
    
is_pal :: String -> Bool
is_pal xs = xs == reverse xs
