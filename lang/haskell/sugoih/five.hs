zipWith' :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith' _ [] _ = []
zipWith' _ _ [] = []
zipWith' f (x:xs) (y:ys) = f x y : zipWith' f xs ys

flip' :: (a -> b -> c) -> (b -> a -> c)
flip' f = g
  where g x y = f y x

-- *Main> zip [1..5] "hello"
-- [(1,'h'),(2,'e'),(3,'l'),(4,'l'),(5,'o')]
-- *Main> flip zip [1..5] "hello"
-- [('h',1),('e',2),('l',3),('l',4),('o',5)]
-- *Main> zipWith' div [2,2..] [10,8,6,4,2]
-- [0,0,0,0,1]
-- *Main> zipWith' (flip' div) [2,2..] [10,8,6,4,2]
-- [5,4,3,2,1]
-- *Main>

-- Prelude> map (+3) [1,4,3,1,6]
-- [4,7,6,4,9]
-- Prelude> map (++ "!") ["BIFF", "BANG", "POW"]
-- ["BIFF!","BANG!","POW!"]
-- Prelude> map (replicate 3) [3..6]
-- [[3,3,3],[4,4,4],[5,5,5],[6,6,6]]
-- Prelude> map (map (^2)) [[1,2],[3,4,5,6],[7,8]]
-- [[1,4],[9,16,25,36],[49,64]]
-- Prelude> map fst [(1,2), (3,5),(6,3),(2,6),(2,5)]
-- [1,3,6,2,2]
-- Prelude> 

filter' :: (a -> Bool) -> [a] -> [a]
filter' _ [] = []
filter' p (x:xs)
  | p x = x : filter p xs
  | otherwise = filter p xs

-- *Main> filter (>3) [1,5,3,2,1,6,4,3,2,1]
-- [5,6,4]
-- *Main> filter (==3) [1,5,3,2,1,6,4,3,2,1]
-- [3,3]
-- *Main> filter even [1..10]
-- [2,4,6,8,10]
-- *Main> let notNull x = not (null x) in filter notNull [[1,2,3],[],[3,4,5],[2,2],[],[]]
-- [[1,2,3],[3,4,5],[2,2]]
-- *Main> filter (`elem` ['a'..'z']) "u LaUgH aT mE BeCaUsE I aM diFfeRent"
-- "uagameasadifeent"
-- *Main>


-- *Main> filter (<15) (filter even [1..20])
-- [2,4,6,8,10,12,14]
-- 同じのを内包表記で書くと
-- *Main> [x | x <- [1..20], x < 15, even x]
-- [2,4,6,8,10,12,14]
-- *Main> 