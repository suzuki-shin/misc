module Main where
import Control.Monad
import Control.Applicative
import System.FilePath ((</>), addTrailingPathSeparator)
import System
import Directory
import Data.Tree
import System.FilePath

-- Tree [path]でtreeコマンドに似た出力をする
main :: IO ()
main = do
  args <- getArgs
  let path = args!!0
  printTree path

printTree :: FilePath -> IO ()
printTree path = do
  t <- tree1 path
--   putStrLn $ unlines $ filter (not . (allIn "| ")) $ lines $ drawTree t         -- ここに'|'と' 'と'\n'だけの行はfilterではじくという処理を挟みたい
  putStrLn $ drawTree t         -- ここに'|'と' 'と'\n'だけの行はfilterではじくという処理を挟みたい

tree1 :: FilePath -> IO (Tree FilePath)
tree1 fullPath = tree parent path
  where (parent, path) = splitFileName fullPath

-- 指定した要素以外が入っていたらFalseを返す 
allIn :: (Eq a ) => [a] -> [a] -> Bool
allIn needles heystack = all (`elem` heystack) needles

-- 再帰的にディレクトリツリーを扱う
--
-- http://codereview.stackexchange.com/questions/8431/how-can-i-make-this-recursive-directory-tree-printer-i-wrote-in-haskell-more-idi
--
tree :: FilePath -> FilePath -> IO (Tree FilePath)
tree parent path = do
  let fullPath = parent </> path
  isDirectory <- doesDirectoryExist fullPath
  if isDirectory
    then do
      paths <- filter (`notElem` [".", ".."]) <$> getDirectoryContents fullPath
      Node (addTrailingPathSeparator path) <$> mapM (tree fullPath) paths
  else return $ Node path []
-- getDirectoryContentsとかの型がFilePath -> IO [FilePath]だからtreeもIOを返すようになってるのか、、、
-- => そうか入出力だからIOなのか

