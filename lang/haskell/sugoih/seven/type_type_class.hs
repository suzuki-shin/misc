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
