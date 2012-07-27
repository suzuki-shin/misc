import System.Random
import Control.Monad (when)

threeCoins :: StdGen -> (Bool, Bool, Bool)
threeCoins gen =
  let (firstCoin, newGen) = random gen
      (secondCoin, newGen') = random newGen
      (thirdCoin, newGen'') = random newGen'
  in (firstCoin, secondCoin, thirdCoin)

-- *Main> threeCoins (mkStdGen 21)
-- (True,True,True)
-- *Main> threeCoins (mkStdGen 22)
-- (True,False,True)
-- *Main> threeCoins (mkStdGen 23)
-- (True,False,True)
-- *Main> threeCoins (mkStdGen 233)
-- (True,True,False)
-- *Main> threeCoins (mkStdGen 233)
-- (True,True,False)
-- *Main> 

-- main = do
--   gen <- getStdGen
--   putStrLn $ take 20 (randomRs ('a', 'z') gen)

main = do
  gen <- getStdGen
  askForNumber gen

askForNumber :: StdGen -> IO ()
askForNumber gen = do
  let (randNumber, newGen) = randomR (1,10) gen :: (Int, StdGen)
  putStrLn "Which number in the range from 1 to 10 am I thinking of?"
  numberString <- getLine
  when (not $ null numberString) $ do
    let number = read numberString
    if randNumber == number
       then putStrLn "You are correct!"
       else putStrLn $ "Sorry, it was " ++ show randNumber
    askForNumber newGen
