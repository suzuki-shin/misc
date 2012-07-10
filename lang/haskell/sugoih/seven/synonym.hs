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
