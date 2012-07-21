data Vector a = Vector a a a deriving (Show)

vplus :: (Num a) => Vector a -> Vector a -> Vector a
(Vector i j k) `vplus` (Vector l m n) = Vector (i+l) (j+m) (k+n)

dotProd :: (Num a) => Vector a -> Vector a -> a
(Vector i j k) `dotProd` (Vector l m n) = i*j + j*m + k*n

vmult :: (Num a) => Vector a -> a -> Vector a
(Vector i j k) `vmult` m = Vector (i*m) (j*m) (k*m)

-- *Main> let v1 = Vector 3 4 5
-- *Main> v1
-- Vector 3 4 5
-- *Main> let v2 = Vector 9 2 8
-- *Main> v1 `vplus` v2
-- Vector 12 6 13
-- *Main> v1 `dotProd` v2
-- 60
-- *Main> v1 `vplus` v2 `vplus` v1
-- Vector 15 10 18
-- *Main> v1 `vmult` 3
-- Vector 9 12 15
-- *Main> v1
-- Vector 3 4 5
