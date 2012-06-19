lucky :: Int -> String
lucky 7 = "LUCKY NUMBER SEVEN!"
lucky _ = "Sorry, you're out of luck, pal!"

factorial :: Int -> Int
factorial 0 = 1
factorial n = n * factorial (n - 1)

add_vectors :: (Double, Double) -> (Double, Double) -> (Double, Double)
add_vectors (x1, y1) (x2, y2) = (x1 + x2, y1 + y2)

-- main = do c <- getContents
--           print $ hoge c

-- hoge :: String -> String
-- hoge x ++ '|' ++ y = x ++ "::" ++ y
-- hoge _ = "hoge"

first :: (a, b, c) -> a
first (x, _, _) = x
second :: (a, b, c) -> b
second (_, y, _) = y
third :: (a, b, c) -> c
third (_, _, z) = z

head' :: [a] -> a
head' [] = error "Can't call heaad on an empty list, dummy!"
head' (x:_) = x

head'' :: [a] -> a
head'' xs = case xs of
  [] -> error "Can't call heaad on an empty list, dummy!"
  (x:_) -> x

tell :: (Show a) => [a] -> String
tell [] = "The list is empty"
tell (x:[]) = "The list has one element: " ++ show x
tell (x:y:[]) = "The list has two elements: " ++ show x ++ " and " ++ show y
tell (x:y:_) = "The list has many elements. The First two elements are: " ++ show x ++ " and " ++ show y

first_letter :: String -> String
first_letter "" = "Empty string, whoops!"
first_letter all@(x:xs) = "The first letter of " ++ all ++ " is " ++ [x]

bmi_tell :: Double -> String
bmi_tell bmi
  | bmi <= 18.5 = "GOOD!"
  | bmi <= 25.0 = "normal"
  | bmi <= 30.0 = "fatty!"
  | otherwise = "whale!!"

bmi_tell2 :: Double -> Double -> String
bmi_tell2 weight height
  | bmi <= skinny  = "GOOD!: " ++ show bmi
  | bmi <= normal  = "normal: " ++ show bmi
  | bmi <= fat     = "fatty!: " ++ show bmi
  | otherwise      = "whale!!: " ++ show bmi
  where bmi     = weight / height ^ 2
        skinny  = 18.5
        normal  = 25.0
        fat     = 30.0

max' :: (Ord a) => a -> a -> a
max' a b
  | a <= b = b
  | otherwise = a

my_compare :: (Ord a) => a -> a -> Ordering
a `my_compare` b
  | a == b = EQ
  | a <= b = LT
  | a > b = GT

cylinder :: Double -> Double -> Double
cylinder r h =
  let side_area = 2 * pi * r * h
      top_area = pi * r ^ 2
  in side_area + 2 * top_area

calc_bmis :: [(Double, Double)] -> [Double]
calc_bmis xs = [bmi | (w, h) <- xs, let bmi = w / h ^ 2]

describe_list :: [a] -> String
describe_list ls = "The list is " ++ case ls of
  [] -> "empty."
  [x] -> "a singleton list."
  xs -> "a longer list."

describe_list' :: [a] -> String
describe_list' ls = "The list is " ++ what ls
  where what [] = "empty."
        what [x] = "a singleton list."
        what xs = "a longer list."
