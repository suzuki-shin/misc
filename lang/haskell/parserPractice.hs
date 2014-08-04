{-# OPTIONS -Wall -fno-warn-unused-do-bind #-}

module ParserPractice where

import Text.Parsec
import Text.Parsec.String
import Data.List
-- import Data.Char
-- import Control.Monad

-- data Lose = Resign | Timeup | Foul deriving (Eq, Show)
-- data Move = Move {getToPos :: String, getFromPos :: Maybe String, getPiece :: String} deriving (Eq, Show)
-- data Action = Lose | Move deriving (Eq, Show)

pieces = ["歩","香","桂","銀","金","玉","角","飛","馬","竜","と","成香","成桂","成銀"]

data KifLine = KifLine {
    getNO :: String
  , getAction :: String
  , getTime :: String
  } deriving (Eq, Show)

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

fromPos :: Parser String
fromPos = do
  pos <- string "打" <|> do
    string "("
    pos <- many1 digit
    string ")"
    return pos
  return pos

-- hoge ５八玉(68) みたいなやつをparseする
hoge :: Parser String
hoge = do
  col <- many1 (oneOf "１２３４５６７８９")
  row <- many1 (oneOf "一二三四五六七八九")
  piece <- many (noneOf "(")
  pos <- fromPos
--   string "("
--   pos <- many1 digit
--   string ")"
  return $ col ++ row ++ piece ++ "(" ++ pos ++ ")"

-- fuga 同　飛(89) みたいなやつをparseする
fuga :: Parser String
fuga = do
  string "同"
  space
  piece <- many1 (noneOf "(")
  string "("
  pos <- many1 digit
  string ")"
  return $ "同" ++ piece ++ "(" ++ pos ++ ")"

-- tohryo 投了 みたいなやつをparseする
tohryo :: Parser String
tohryo = string "投了"

kifLine :: Parser KifLine
kifLine = do
  no <- many1 digit
  space
  action <- hoge <|> fuga <|> tohryo
  space
  time <- many1 (noneOf "\n")
  return $ KifLine no action time

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

kifLines :: Parser [KifLine]
kifLines = endBy1 kifLine eol

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
  let c = "85 ５八玉(68)   ( 00:04/00:04:38)"
  case parse kifLine "(kif)" c of
    Left err -> print err
    Right res -> print res

-- main = do
--   file <- readFile "logfile.txt"
--   let logLines = lines file
--   result <- map (parse logLine "(test)") logLines
--   return ()
--   mapM_ (either print print) result

