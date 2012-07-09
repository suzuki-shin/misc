module Shape
       ( Point
       , Shape
       , area
       , nudge
       , baseCircle
       , baseRect
       ) where

data Point = Point Float Float deriving (Show)
data Shape = Circle Point Float | Rectangle Point Point deriving (Show)

area :: Shape -> Float
area (Circle _ r) = r ^ 2 * pi
area (Rectangle (Point x1 y1) (Point x2 y2)) = (abs $ x2 - x1) * (abs $ y2 - y1)

-- *Main> area $ Circle 10 3 8
-- 201.06194
-- *Main> Circle 3 30 32.0
-- Circle 3.0 30.0 32.0
-- 値コンストラクタは関数なので、普通にmapしたり、部分適用したりできる
-- *Main> map (Circle 10 20) [4,5,6,6]
-- [Circle 10.0 20.0 4.0,Circle 10.0 20.0 5.0,Circle 10.0 20.0 6.0,Circle 10.0 20.0 6.0]

-- *Main> area (Rectangle (Point 0 0 ) (Point 100 100))
-- 10000.0
-- *Main> area (Circle (Point 0 0) 24)
-- 1809.5574

--図形を動かす関数
nudge :: Shape -> Float -> Float -> Shape
nudge (Circle (Point x y) r) a b = Circle (Point (x+a) (y+b)) r
nudge (Rectangle (Point x1 y1) (Point x2 y2)) a b
  = Rectangle (Point (x1+a) (y1+b)) (Point (x2+a) (y2+b))

-- *Main> let c = Circle (Point 0 0) 10
-- *Main> c
-- Circle (Point 0.0 0.0) 10.0
-- *Main> let r = Rectangle (Point 0 0) (Point 10 20)
-- *Main> r
-- Rectangle (Point 0.0 0.0) (Point 10.0 20.0)
-- *Main> area c
-- 314.15927
-- *Main> area r
-- 200.0
-- *Main> nudge c 5 9
-- Circle (Point 5.0 9.0) 10.0
-- *Main> nudge r 5 9
-- Rectangle (Point 5.0 9.0) (Point 15.0 29.0)

baseCircle :: Float -> Shape
baseCircle r = Circle (Point 0 0) r
baseRect :: Float -> Float -> Shape
baseRect width height = Rectangle (Point 0 0) (Point width height)
