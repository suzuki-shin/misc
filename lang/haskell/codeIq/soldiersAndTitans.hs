{-# OPTIONS_GHC -Wall #-}

data Pos = L | R deriving (Show,Eq)
type SoldierNum = Int
type TitanNum = Int
data Status = Status {leftStatus :: (SoldierNum, TitanNum), shipPos :: Pos} deriving (Show, Eq)

toStr :: Status -> String
toStr (Status (s,t) _) = replicate s 'S' ++ replicate t 'T' ++ "/" ++ replicate (soldierNum-s) 'S' ++ replicate (titanNum-t) 'T'

soldierNum, titanNum, shipCapa :: Int
soldierNum = 3
titanNum = 3
shipCapa = 2

startStatus :: Status
startStatus = Status (soldierNum, titanNum) L

goalStatus :: Status
goalStatus = Status (0,0) R

movePos :: Pos -> Pos
movePos L = R
movePos R = L

-- 指定した状態の次の状態のリストを返す
move' :: Int -> Status -> [Status]
move' capa (Status (s,t) L) = [Status (s-moveS,t-moveT) R |moveS<-[capa,capa-1..0], moveT<-[capa,capa-1..0], moveS+moveT `elem` [1..capa], s-moveS >= 0,t-moveT >= 0]
move' capa (Status (s,t) R) = [Status (s+moveS,t+moveT) L |moveS<-[capa,capa-1..0], moveT<-[capa,capa-1..0], moveS+moveT `elem` [1..capa], s+moveS <= soldierNum,t+moveT <= titanNum]

move :: Status -> [Status]
move = move' shipCapa

-- 指定した左側の数で、兵士が無事でいられるか
isSafe :: (SoldierNum, TitanNum) -> Bool
isSafe (s,t) = s == t || s == soldierNum || s == 0

-- とりあえず全てのルートを求める
searchRoute :: Status -> [Status] -> [[Status]]
searchRoute st route =
  if st `elem` route || not (isSafe (leftStatus st))
    then return []
    else do
      st' <- move st
      if st' == goalStatus
        then return $ st:route
        else searchRoute st' (st:route)

main :: IO ()
main = mapM_ print $ map (reverse . (map toStr)) $ (filter (/=[]) (searchRoute startStatus []))