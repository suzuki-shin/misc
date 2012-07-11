module Hoge where
import qualified Data.Map as Map

type PhoneBook = [(Name, PhoneNumber)]
type Name = String
type PhoneNumber = String

inPhoneBook :: Name -> PhoneNumber -> PhoneBook -> Bool
inPhoneBook name pnumber pbook = (name, pnumber) `elem` pbook

-- 型シノニムの多相化
type AssocList k v = [(k,v)]

-- 例として生徒一人一人のロッカーが割り当てられている高校を考えてみる
data LockerState = Taken | Free deriving (Show, Eq) -- ロッカーの状態
type Code = String              -- ロッカーの暗証番号
type LockerMap = Map.Map Int (LockerState, Code)
-- ロッカーを表すMapから暗証番号を検索する関数
lockerLookup :: Int -> LockerMap -> Either String Code
lockerLookup lockerNumber map = case Map.lookup lockerNumber map of
  Nothing -> Left $ "Locker " ++ show lockerNumber ++ " doesn't exist!"
  Just (state, code) -> if state /= Taken
                          then Right code
                          else Left $ "Locker " ++ show lockerNumber ++ " is already taken!"

lockers :: LockerMap
lockers = Map.fromList
          [(100, (Taken, "ZD391"))
          ,(102, (Free, "JAH3I"))
          ,(103, (Free, "ISQS0"))
          ,(105, (Free, "!QD87"))
          ,(109, (Taken, "8989J"))
          ,(110, (Taken, "03123"))
          ]

-- *Main> lockerLookup 101 lockers
-- Left "Locker 101 doesn't exist!"
-- *Main> lockerLookup 100 lockers
-- Left "Locker 100 is already taken!"
-- *Main> lockerLookup 102 lockers
-- Right "JAH3I"
-- *Main> lockerLookup 105 lockers
-- Right "!QD87"

--
-- 7.7 再帰的なデータ構造 
--
-- -- 独自のリスト型
-- data List a = Empty | Cons a (List a) deriving (Show, Read, Eq, Ord)
-- -- もしくは
-- data List a = Empty | Cons {listHead :: a, listTail :: List a} deriving (Show, Read, Eq, Ord)
-- 記号文字だけを使って関数に名前をつけると自動的に中置関数になる。ただし関数名は:で始まる必要がある
infixr 5 :-:
data List a = Empty | a :-: (List a) deriving (Show, Read, Eq, Ord)
-- *Main> 3 :-: 4 :-: 5 :-: Empty
-- 3 :-: (4 :-: (5 :-: Empty))
-- *Main> let a = 3 :-: 4 :-: 5 :-: Empty
-- *Main> a
-- 3 :-: (4 :-: (5 :-: Empty))
-- *Main> 100 :-: a
-- 100 :-: (3 :-: (4 :-: (5 :-: Empty)))

infixr 5 ^++
(^++) :: List a -> List a -> List a
Empty ^++ ys = ys
(x :-: xs) ^++ ys = x :-: (xs ^++ ys)
-- *Main> let a = 3 :-: 4 :-: 5 :-: Empty
-- *Main> let b = 100 :-: a
-- *Main> b
-- 100 :-: (3 :-: (4 :-: (5 :-: Empty)))
-- *Main> a ^++ b
-- 3 :-: (4 :-: (5 :-: (100 :-: (3 :-: (4 :-: (5 :-: Empty))))))
-- *Main> a ^++ Empty
-- 3 :-: (4 :-: (5 :-: Empty))
-- *Main> Empty ^++ a
-- 3 :-: (4 :-: (5 :-: Empty))

-- infixr 5 ++
-- (++) :: List a -> List a -> List a
-- Empty ++ ys = ys
-- (x :-: xs) ++ ys = x :-: (xs ++ ys)
-- 上のようにやろうとしたら下のようにエラーになった
-- /Users/ent-imac/projects/misc/lang/haskell/sugoih/seven/type_type_class.hs:20:31:
--     Ambiguous occurrence `++'
--     It could refer to either `Main.++',
--                              defined at /Users/ent-imac/projects/misc/lang/haskell/sugoih/seven/type_type_class.hs:79:7
--                           or `Prelude.++', imported from Prelude

data Tree a = EmptyTree | Node a (Tree a) (Tree a) deriving (Show)

singleton :: a -> Tree a
singleton x = Node x EmptyTree EmptyTree

treeInsert :: (Ord a) => a -> Tree a -> Tree a
treeInsert x EmptyTree = singleton x
treeInsert x (Node a left right)
 | x == a = Node x left right
 | x < a  = Node a (treeInsert x left) right
 | x > a  = Node a left (treeInsert x right)

treeElem :: (Ord a) => a -> Tree a -> Bool
treeElem x EmptyTree = False
treeElem x (Node a left right)
  | x == a = True
  | x < a  = treeElem x left
  | x > a  = treeElem x right

-- *Hoge> let nums = [8,6,4,1,7,3,5]
-- *Hoge> let numsTree = foldr treeInsert EmptyTree nums
-- *Hoge> numsTree
-- Node 5 (Node 3 (Node 1 EmptyTree EmptyTree) (Node 4 EmptyTree EmptyTree)) (Node 7 (Node 6 EmptyTree EmptyTree) (Node 8 EmptyTree EmptyTree))
-- *Hoge> 8 `treeElem` numsTree
-- True
-- *Hoge> 100 `treeElem` numsTree
-- False
-- *Hoge> 1 `treeElem` numsTree
-- True
-- *Hoge> 10 `treeElem` numsTree
-- False

-- 交通信号データ型
data TrafficLight = Red | Yellow | Green
-- Eq型クラスのインスタンスにする
instance Eq TrafficLight where
  -- Eqのメソッドを実装する
  Red == Red = True
  Green == Green = True
  Yellow == Yellow = True
  _ == _ = False
-- Show型クラスのインスタンスにする
instance Show TrafficLight where
  -- Showのメソッドを実装する
  show Red = "Red light"
  show Yellow = "Yellow light"
  show Green = "Green light"

-- *Hoge> Red == Red
-- True
-- *Hoge> Red == Green
-- False
-- *Hoge> Red `elem` [Red, Yellow, Green]
-- True
-- *Hoge> Red
-- Red light
-- *Hoge> [Red, Yellow, Green]
-- [Red light,Yellow light,Green light]

-- instance (Eq m) => Eq (Maybe m) where
--   Just x == Just y = x == y
--   Nothing == Nothing = True
--   _ == _ = False

-- YesとNoの型クラス
class YesNo a where
  yesno :: a -> Bool

instance YesNo Int where
  yesno 0 = False
  yesno _ = True

instance YesNo [a] where
  yesno [] = False
  yesno _ = True

instance YesNo Bool where
  yesno = id

instance YesNo (Maybe a) where
  yesno (Just _) = True
  yesno Nothing = False

instance YesNo (Tree a) where
  yesno EmptyTree = False
  yesno _ = True

instance YesNo TrafficLight where
  yesno Red = False
  yesno _ = True

-- *Hoge> yesno $ length []
-- False
-- *Hoge> yesno "haha"
-- True
-- *Hoge> yesno ""
-- False
-- *Hoge> yesno $ Just 0
-- True
-- *Hoge> yesno True
-- True
-- *Hoge> yesno EmptyTree
-- False
-- *Hoge> yesno []
-- False
-- *Hoge> yesno [0,0,0]
-- True
-- *Hoge> :t yesno
-- yesno :: YesNo a => a -> Bool
