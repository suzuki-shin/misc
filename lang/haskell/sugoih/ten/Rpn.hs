{-# OPTIONS -Wall #-}

solveRPN :: String -> Double
solveRPN = head . foldl foldingFunction [] . words
  where
--     foldingFunction :: Floating a => [a] -> String -> [a]
    foldingFunction :: (Read a, Floating a) => [a] -> [Char] -> [a]
    foldingFunction (x:y:ys) "*" = (y * x) :ys
    foldingFunction (x:y:ys) "+" = (y + x) :ys
    foldingFunction (x:y:ys) "-" = (y - x) :ys
    foldingFunction (x:y:ys) "/" = (y / x) :ys
    foldingFunction (x:y:ys) "^" = (y ** x) :ys
    foldingFunction (x:xs) "ln" = log x:xs
    foldingFunction xs "sum" = [sum xs]
    foldingFunction xs numberString = read numberString:xs
