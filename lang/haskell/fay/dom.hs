{-# LANGUAGE EmptyDataDecls #-}
module Dom where

import Language.Fay.FFI
import Language.Fay.Prelude

main :: Fay ()
main = do
  result <- documentGetElements "body"
  fprint result

fprint :: Foreign a => a -> Fay ()
fprint = ffi "console.log" ""

data Element
instance Foreign Element

documentGetElements :: String -> Fay [Element]
documentGetElements =
  ffi "document.getElementsByTagName"
      "array"
