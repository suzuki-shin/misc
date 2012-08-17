-- fib :: Int -> Int
-- fib 0 = 0
-- fib 1 = 1
-- fib n = fib (n-1) + fib (n-2)

-- fib :: Int -> Integer
-- fib n = (flist) !! n
--     where
--      flist :: [Integer]
--      flist = 0:1:[x + y |(x,y) <- zip flist (tail flist)]

fib :: Int -> Maybe Int
fib 0 = Just 0
fib 1 = Just 1
fib n | n < 0 = Nothing
      | otherwise = Just (fib (n-1) + fib (n-2))
