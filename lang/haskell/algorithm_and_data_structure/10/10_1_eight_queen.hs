{-# OPTIONS_GHC -Wall #-}
--  エイトクイーンをバックトラックで解く
import qualified Data.Map as M

type Pos = (Int, Int)
type Board = M.Map Pos Bool

-- | チェスのボード
board :: Board
board = M.fromList [((x,y), False)|x<-[0..7],y<-[0..7]]

-- | (x,y)にクイーンが置けるかを返す (まだdoctestが通らない)
-- >>> check (0,0) $ M.fromList [((0,0),False),((1,0),False),((0,1),False),((1,1),False)]
-- True
-- >>> check (0,0) $ M.fromList [((0,0),True),((1,0),False),((0,1),False),((1,1),False)]
-- False
check :: Pos -> Board -> Bool
check p b = checkLeft p b && checkLeftUp p b && checkLeftDown p b
      where
        checkLeft :: Pos -> Board -> Bool
        checkLeft (x,y) b' = 0 == (M.size $ M.filterWithKey (\(x',y') e -> y' == y && x' < x && e == True) b')
        checkLeftUp :: Pos -> Board -> Bool
        checkLeftUp (x,y) b' = 0 == (M.size $ M.filterWithKey (\(x',y') e -> y' == y+1 && x' < x && e == True) b')
        checkLeftDown :: Pos -> Board -> Bool
        checkLeftDown (x,y) b' = 0 == (M.size $ M.filterWithKey (\(x',y') e -> y' == y-1 && x' < x && e == True) b')


main :: IO ()
main = print $ check (0,0) board