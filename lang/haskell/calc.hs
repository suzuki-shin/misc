import Text.ParserCombinators.Parsec
import Char

main = do c <- getContents
          print c

type Pos = (Int, Int)

beep :: IO ()
beep = putStr "\BEL"

cls :: IO ()
cls = putStr "\ESC[2J"

goto :: Pos -> IO ()
goto (x, y) = putStr ("\ESC[" ++ show y ++ ";" ++ show x ++"H")

box :: [String]
box = ["+---------------+",
       "|               |",
       "+---+---+---+---+",
       "| q | c | d | = |",
       "+---+---+---+---+",
       "| 1 | 2 | 3 | + |",
       "+---+---+---+---+",
       "| 4 | 5 | 6 | - |",
       "+---+---+---+---+",
       "| 7 | 8 | 9 | * |",
       "+---+---+---+---+",
       "| 0 | ( | ) | / |",
       "+---+---+---+---+"
      ]

seqn :: [IO a] -> IO ()
seqn [] = return ()
seqn (a:as) = do a
                 seqn as

writeat :: Pos -> String -> IO ()
writeat p xs = do goto p
                  putStr xs

buttons :: [Char]
buttons = standard ++ extra
          where
            standard = "qcd=123+456-789*0()/"
            extra = "QCD \ESC\BS\DEL\n"

showbox :: IO ()
showbox = seqn [writeat (1,y) xs|(y,xs) <- zip [1..13] box]

display :: String -> IO ()
display xs = do writeat (3,2) "                   "
                writeat (3,2) (reverse (take 13 (reverse xs)))

calc :: String -> IO ()
calc xs = do display xs
             c <- getChar
             if elem c buttons then
                 process c xs
               else
                 do beep
                    calc xs

process :: Char -> String -> IO ()
process c xs
  | elem c "qQ\ESC" = quit
  | elem c "dD\BS\DEL" = delete xs
  | elem c "=\n" = eval xs
  | elem c "cC" = clear
  | otherwise = press c xs

quit :: IO ()
quit = goto (1,14)

delete :: String -> IO ()
delete "" = calc ""
delete xs = calc (init xs)

eval :: String -> IO ()
eval xs = case parse expr xs of
  [(n,"")] -> calc (show n)
  _        -> do beep
                 calc xs

clear :: IO ()
clear = calc ""

press :: Char -> String -> IO ()
press c xs = calc (xs ++ [c])

run :: IO ()
run = do cls
         showbox
         clear

expr :: Parser Int
expr = do t <- term
          do symbol "+"
             e <- expr
             return (t + e)
           <|> return t

term :: Parser Int
term = do f <- factor
          do symbol "*"
             t <- term
             return (f * t)
           <|> return f

factor :: Parser Int
factor = do symbol "("
            e <- expr
            symbol ")"
            return e
         <|> natural

symbol :: String -> Parser String
symbol xs = token (string xs)

natural :: Parser Int
natural = token nat

nat :: Parser Int
nat = do xs <- many1 digit
         return (read xs)