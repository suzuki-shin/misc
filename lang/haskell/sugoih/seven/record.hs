-- レコード構文
data Person = Person { firstName :: String
                     , lastName:: String
                     , age :: Int
                     , height :: Float
                     , phoneNumber :: String
                     , flavor :: String }
            deriving (Show, Eq, Read)

data Car = Car { company :: String
             , model :: String
             , year :: Int
             } deriving (Show, Read)

-- *Main> Car "Ford" "Mustang" 1967
-- Car {company = "Ford", model = "Mustang", year = 1967}
-- *Main> let c = Car "Ford" "Mustang" 1967
-- *Main> c
-- Car {company = "Ford", model = "Mustang", year = 1967}
-- *Main> model c
-- "Mustang"

tellCar :: Car -> String
tellCar (Car {company = c, model = m, year = y}) = "This " ++ c ++ " " ++ m ++ " was made in " ++ show y

data Day = Monday | Tuesday | Wednesday | Thursday
         | Friday | Saturday | Sunday deriving (Show, Ord, Eq, Read, Bounded, Enum)
