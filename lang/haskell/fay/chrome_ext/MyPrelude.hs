{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module MyPrelude where

import Prelude
-- import FFI

listToMaybe           :: [a] -> Maybe a
listToMaybe []        =  Nothing
listToMaybe (a:_)     =  Just a

fromJust          :: Maybe a -> a
fromJust Nothing  = error "Maybe.fromJust: Nothing" -- yuck
fromJust (Just x) = x

elemIndex       :: Eq a => a -> [a] -> Maybe Int
elemIndex x     = findIndex (x==)

findIndex       :: (a -> Bool) -> [a] -> Maybe Int
findIndex p     = listToMaybe . findIndices p

findIndices      :: (a -> Bool) -> [a] -> [Int]
findIndices p xs = [ i | (x,i) <- zip xs [0..], p x]

-- split :: ([a] -> Bool) -> [a] -> ([a], [a])
split f xs = (fst (break f xs), dropWhile f (snd (break f xs)))

tails                   :: [a] -> [[a]]
tails xs                =  xs : case xs of
                                  []      -> []
                                  _ : xs' -> tails xs'

isPrefixOf              :: (Eq a) => [a] -> [a] -> Bool
isPrefixOf [] _         =  True
isPrefixOf _  []        =  False
isPrefixOf (x:xs) (y:ys)=  x == y && isPrefixOf xs ys

isInfixOf :: (Eq a) => [a] -> [a] -> Bool
isInfixOf needle haystack = any (isPrefixOf needle) (tails haystack)

-- toLower c = chr (fromIntegral (towlower (fromIntegral (ord c))))
-- toUpper c = chr (fromIntegral (towupper (fromIntegral (ord c))))

-- ord :: Char -> Int
-- ord (C# c#) = I# (ord# c#)

-- chr :: Int -> Char
-- chr i@(I# i#)
--  | int2Word# i# `leWord#` 0x10FFFF## = C# (chr# i#)
--  | otherwise = error ("Prelude.chr: bad argument: " ++ showSignedInt (I# 9#) i "")
