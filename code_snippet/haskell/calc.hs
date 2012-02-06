import Text.ParserCombinators.Parsec

main = do c <- getContents
          print c

float  :: Parser Float
float   = do a <- number
             char '.'
             b <- number
             return $ fromIntegral a + pnt (fromIntegral b)
               where
                 pnt n = if n < 1 then n
                         else pnt (n / 10)
number :: Parser Int
number  = do n <- many1 digit
             return $ read n

