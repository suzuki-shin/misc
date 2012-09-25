import qualified Data.Map as M
import Board

boardSize :: Int
boardSize = 3

winningPatterns :: [[Pos]]
winningPatterns = [[(1,1),(1,2),(1,3)], [(2,1),(2,2),(2,3)], [(3,1),(3,2),(3,3)], -- 横
                   [(1,1),(2,1),(3,1)], [(1,2),(2,2),(3,2)], [(1,3),(2,3),(3,3)], -- 縦
                   [(1,1),(2,2),(3,3)], [(3,1),(2,2),(1,3)]] -- 斜

main :: IO ()
main = do
  let boardInfo = emptyBoard boardSize
  roop boardInfo winningPatterns O
