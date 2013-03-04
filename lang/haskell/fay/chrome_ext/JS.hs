{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE EmptyDataDecls    #-}

module JS where

import Prelude
import FFI

data JQuery
instance Show JQuery

data Element

printArg :: a -> Fay ()
printArg = ffi "console.log(\"%%o\",%1)"

showDouble :: Double -> String
showDouble = ffi "(%1).toString()"

showString :: String -> String
showString = ffi "JSON.stringify(%1)"

select :: String -> Fay JQuery
select = ffi "jQuery(%1)"

addClassWith :: (Double -> String -> Fay String) -> JQuery -> Fay JQuery
addClassWith = ffi "%2.addClass(%1)"

ready :: Fay () -> Fay ()
ready = ffi "jQuery(%1)"

localStorageSet :: String -> String -> Fay ()
localStorageSet = ffi "localStorage.setItem(%1, %2)"

localStorageGet :: String -> String
localStorageGet = ffi "localStorage.getItem(%1)"

remove :: JQuery -> Fay JQuery
remove = ffi "%1.remove()"

append :: String -> JQuery -> Fay JQuery
append = ffi "%2.append(%1)"

appendJ :: JQuery -> JQuery -> Fay JQuery
appendJ = ffi "%2.append(%1)"

addClass :: String -> JQuery -> Fay JQuery
addClass = ffi "%2.addClass(%1)"

data Event

getKeyCode :: Event -> Int
getKeyCode = ffi "%1.keyCode"

keyup :: (Event -> Fay ()) -> Fay ()
keyup = ffi "$(document).keyup(%1)"
keydown :: (Event -> Fay ()) -> Fay ()
keydown = ffi "$(document).keydown(%1)"

jqClick :: JQuery -> Fay JQuery
jqClick = ffi "%1.click()"

jqHtml :: (Int -> String -> String) -> JQuery -> Fay String
jqHtml = ffi "%2.html(%1)"

jqRemoveClass :: String -> JQuery -> Fay JQuery
jqRemoveClass = ffi "%2.removeClass(%1)"

jqRemove :: JQuery -> Fay JQuery
jqRemove = ffi "%1.remove()"

jqEq :: Int -> JQuery -> Fay JQuery
jqEq = ffi "%2.eq(%1)"

jqIdx :: Int -> JQuery -> Fay JQuery
jqIdx = ffi "%2[%1]"

jqShow :: JQuery -> Fay JQuery
jqShow = ffi "%1.show()"

jqHide :: JQuery -> Fay JQuery
jqHide = ffi "%1.hide()"

jqFocus :: JQuery -> Fay JQuery
jqFocus = ffi "%1.focus()"

jqBlur :: JQuery -> Fay JQuery
jqBlur = ffi "%1.blur()"

on :: String -> String -> (Event -> Fay ()) -> JQuery -> Fay JQuery
on = ffi "%4.on(%1, %2, %3)"

preventDefault :: Event -> Fay ()
preventDefault = ffi "%1.preventDefault()"

data Ref a

newRef :: a -> Fay (Ref a)
newRef = ffi "new Fay$$Ref(%1)"

writeRef :: Ref a -> a -> Fay ()
writeRef = ffi "Fay$$writeRef(%1,%2)"

readRef :: Ref a -> Fay a
readRef = ffi "Fay$$readRef(%1)"

arrToStr :: [Char] -> Fay String
arrToStr = ffi "%1.join('')"

arrToStr' :: [Char] -> String
arrToStr' = ffi "%1.join('')"

nodeName :: JQuery -> String
nodeName = ffi "%1.nodeName"

toLowerCase :: String -> String
toLowerCase = ffi "%1.toLowerCase()"

attr :: String -> JQuery -> String
attr = ffi "%2.attr(%1)"

setAttr :: String -> String -> JQuery -> Fay JQuery
setAttr = ffi "%3.attr(%1, %2)"

jqNext :: String -> JQuery -> Fay JQuery
jqNext = ffi "%2.next(%1)"

jqPrev :: String -> JQuery -> Fay JQuery
jqPrev = ffi "%2.prev(%1)"

jqText :: JQuery -> Fay String
jqText = ffi "%1.text()"

jqVal :: JQuery -> Fay String
jqVal = ffi "%1.val()"

concatJQuery :: [JQuery] -> Fay JQuery
concatJQuery = ffi "$(%1)"