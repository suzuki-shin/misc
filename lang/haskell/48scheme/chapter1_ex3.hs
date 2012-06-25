module Main where
import System.Environment

main :: IO ()
main = do
  putStrLn "Input your name"
  l <- getLine
  putStrLn $ "You are " ++ l
