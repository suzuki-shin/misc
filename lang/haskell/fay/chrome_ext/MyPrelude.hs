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