main = do c <- getContents
          print $ fizzbuzz [1..read c :: Int]

fizzbuzz :: [Int] -> [String]
fizzbuzz (i:is) = (fb i : fizzbuzz is)
                  where fb :: Int -> String
                        fb i | i `mod` 15 == 0  = "FizzBuzz"
                             | i `mod` 5 == 0   = "Buzz"
                             | i `mod` 3 == 0   = "Fizz"
                             | otherwise        = show i :: String
fizzbuzz [] = []
