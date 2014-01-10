{-# LANGUAGE Arrows, NoMonomorphismRestriction #-}
module Scraper where

import Text.XML.HXT.Core
import Text.XML.HXT.Curl

data Guest = Guest { firstName, lastName :: String }
  deriving (Show, Eq)

getGuest = deep (isElem >>> hasName "guest") >>> 
  proc x -> do
    fname <- getText <<< getChildren <<< deep (hasName "fname") -< x
    lname <- getText <<< getChildren <<< deep (hasName "lname") -< x
    returnA -< Guest { firstName = fname, lastName = lname }

hoge = deep (isElem >>> hasName "guest") >>> 
  proc x -> do
    fname <- getText <<< getChildren <<< deep (hasName "fname") -< x
    lname <- getText <<< getChildren <<< deep (hasName "lname") -< x
    returnA -< (fname, lname)
