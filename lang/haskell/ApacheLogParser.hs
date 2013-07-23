{-# OPTIONS -Wall -fno-warn-unused-do-bind #-}

-- http://delihiros.hatenablog.jp/entry/2012/06/12/174635

module ApacheLogParser where

import Text.Parsec
import Text.Parsec.String
import Data.List

-- "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" - - \"%{X-DCMGUID}i\" \"%{X-Up-Subno}i\" \"%{x-jphone-uid}i\" \"%{MOAPPS_CARRIER}e\" \"%{sp_uk}C\" \"%{sp_sess}C\" \"%Tsec\""
data LogLine = LogLine {
    getIP :: String
  , getIdent :: String
  , getUser :: String
  , getDate :: String
  , getReq :: String
  , getStatus :: String
  , getBytes :: String
  , getRef :: String
  , getUA :: String
  , getDCMGUID :: String
  , getUpSubno :: String
  , getJphoneUid :: String
  , getMoappsCarrier :: String
  , getSpUk :: String
  -- , getSpSecc :: String
  -- , getSec :: String
  } deriving (Ord, Eq, Show)

plainValue :: Parser String
plainValue = many1 (noneOf " \n")

bracketedValue :: Parser String
bracketedValue = do
  char '['
  content <- many (noneOf "]")
  char ']'
  return content

quotedValue :: Parser String
quotedValue = do
  char '"'
  content <- many (noneOf "\"")
  char '"'
  return content

logLine :: Parser LogLine
logLine = do
  ip <- plainValue
  space
  ident <- plainValue
  space
  user <- plainValue
  space
  date <- bracketedValue
  space
  req <- quotedValue
  space
  status <- plainValue
  space
  bytes <- plainValue
  space
  ref <- quotedValue
  space
  ua <- quotedValue
  space
  char '-'
  space
  char '-'
  space
  dcmguid <- quotedValue
  space
  upsubno <- quotedValue
  space
  jphoneuid <- quotedValue
  space
  moappscarrier <- quotedValue
  space
  spuk <- quotedValue
  return $ LogLine ip ident user date req status bytes ref ua dcmguid upsubno jphoneuid moappscarrier spuk
  -- space
  -- spsecc <- quotedValue
  -- space
  -- sec <- quotedValue
  -- return $ LogLine ip ident user date req status bytes ref ua dcmguid upsubno jphoneuid moappscarrier spuk spsecc sec

logLines :: Parser [LogLine]
logLines = endBy1 logLine eol

eol =     try (string "\n\r")
      <|> try (string "\r\n")
      <|> string "\n"
      <|> string "\r"


uniqueUAList :: [LogLine] -> [String]
uniqueUAList = map (\uaList -> uaList!!0) . group . sort . map (\log -> getUA log)

uniqueElementList :: (LogLine -> String) ->  [LogLine] -> [String]
uniqueElementList elem = map (\uaList -> uaList!!0) . group . sort . map (\log -> elem log)


-- testLine = "192.168.1.80 - - [18/Feb/2011:20:21:30 +0100] \"GET / HTTP/1.0\" 503 2682 \"-\" \"-\""

-- main = case parse logLine "(test)" testLine of
--   Left err -> print err
--   Right res -> print res

main :: IO ()
main = do
  c <- getContents
  case parse logLines "(test)" c of
    Left err -> print err
    Right res -> mapM_ (print . getUA) res

-- main = do
--   file <- readFile "logfile.txt"
--   let logLines = lines file
--   result <- map (parse logLine "(test)") logLines
--   return ()
--   mapM_ (either print print) result