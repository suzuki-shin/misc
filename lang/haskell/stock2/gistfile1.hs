{-# LANGUAGE Arrows, FlexibleContexts #-}

module Main where 

import Text.XML.HXT.Core
import Text.XML.HXT.Arrow.XmlArrow
import Control.Arrow

import qualified Text.XML.HXT.DOM.XmlNode as XN
import Data.List

chapterToH1 :: (ArrowXml a) => a XmlTree XmlTree
chapterToH1 = 
    processBottomUp
    (ifA (hasName "div" >>> hasAttrValue "class" (=="chapter"))
             ((setElemName $ mkName "h1") >>> removeAttr "class")
             (this))

spanClassToElem :: (ArrowXml a) => 
                   String            -- if SPAN is this class,
                -> String            -- turn that into thie element.
                -> a XmlTree XmlTree
spanClassToElem cls elm = 
    processTopDown
    (ifA (hasName "span" >>> isClass cls)
             (tameClass elm)
             (this))

divClassToElem :: (ArrowXml a) => 
                  String            -- if DIV is this class, 
               -> String            -- turn that into this element.
               -> a XmlTree XmlTree
divClassToElem cls elm = 
    processTopDown
    (ifA (hasName "div" >>> isClass cls)
             (tameClass elm)
             (this))

tameClass :: (ArrowXml a) => String -> a XmlTree XmlTree
tameClass elm = (setElemName $ mkName elm) >>> 
                removeAttr "class"

isClass :: (ArrowXml a) => String -> a XmlTree XmlTree
isClass val = hasAttrValue "class" (==val)


groupBullet :: [XmlTree] -> [XmlTree]
groupBullet ts = map bulletlines $ groupBy isBullet ts
  where bulletlines [x] = x
        bulletlines a@(x:xs) = XN.mkElement (mkName "ul") [] a

isBullet :: XmlTree -> XmlTree -> Bool
isBullet t1 t2 = case (XN.getElemName t1, XN.getElemName t2) of
  (Just x', Just y') -> let x = qualifiedName x'
                            y = qualifiedName y'
                        in    (isPrefixOf "bullet" x)
                           && (isPrefixOf "bullet" y)
                           && (not $ isPrefixOf "bulletA" y)
  (_, _) -> False

bulletToLi :: (ArrowXml a) => a XmlTree XmlTree
bulletToLi = 
    choiceA [isClassPrefixOf "bullet" :-> (tameClass "li"),
             this :-> this]

isClassPrefixOf :: (ArrowXml a) => String -> a XmlTree XmlTree
isClassPrefixOf val =     
    (hasAttrValue "class" (isPrefixOf val))

classValToName :: (ArrowXml a) => String -> a XmlTree XmlTree
classValToName cls = 
    setElemName $< ((isClassPrefixOf cls 
                     >>> getAttrValue "class" 
                     >>> arr mkName)
                    `orElse`
                    getElemName)


main :: IO ()
main = do
  r <- runX (readDocument [] "test.html"
        >>>
--        chapterToH1
--        >>>
        (seqA . map (uncurry divClassToElem)
                  $ [("chapter", "h1")
                    ,("section", "h2")
                    ,("para", "p")
                    ])
        >>>
        (seqA . map (uncurry spanClassToElem)
                  $ [("shell", "code")
                    ,("haskell", "code")
                    ])
        >>>
        processTopDown 
        (((getChildren >>> classValToName "bullet")
          >>. groupBullet)
         `when` (hasName "body"))
        -- >>>
        -- processTopDown bulletToLi
        -- >>>
        -- writeDocument [withIndent yes] "result1.html"
        )
  mapM_ print r
  return ()

