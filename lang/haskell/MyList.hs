module MyList (isIn) where

-- | あるリストの全ての要素が別のリストに含まれるかを返す
-- >>> [1,2,3] `isIn` [3,1,2,4,5]
-- True
-- >>> [1,2,3] `isIn` [1,2,4,5]
-- False
-- >>> [] `isIn` [1,2,4,5]
-- True
-- >>> [] `isIn` []
-- True
-- >>> [(1,2),(2,3)] `isIn` [(3,3),(1,2),(4,5),(2,3)]
-- True
isIn :: Eq a => [a] -> [a] -> Bool
(x:xs) `isIn` ys = (x `elem` ys) && (xs `isIn` ys)
[] `isIn` _ = True
