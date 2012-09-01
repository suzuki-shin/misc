-- http://ideone.com/ciKtm
import Control.Applicative
import Data.Maybe
import Data.Monoid

fizz = cycle [Nothing, Nothing, Just "Fizz"]
buzz = cycle [Nothing, Nothing, Nothing, Nothing, Just "Buzz"]
nums = map (Just . show) [1..100]

-- (<>) = mappend -- for ghc < 7.4

main :: IO ()
main =
  mapM_ putStrLn
  $ catMaybes
  $ zipWith3 (\f b n -> f <> b <|> n) fizz buzz nums
