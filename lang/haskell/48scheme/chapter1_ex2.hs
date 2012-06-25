module Main where
import System.Environment

main :: IO ()
main = do
  args <- getArgs
--   putStrLn $ "+: " ++ show $ read (args !! 0) + read (args !! 1) -- 下のが良くてこれがだめな理由がわからん
  putStrLn $ "+: " ++ show (read (args !! 0) + read (args !! 1))
  putStrLn $ "-: " ++ show (read (args !! 0) - read (args !! 1))
  putStrLn $ "*: " ++ show (read (args !! 0) * read (args !! 1))
