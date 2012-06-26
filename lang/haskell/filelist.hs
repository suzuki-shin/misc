module Main where
import Control.Monad
import Control.Applicative
import System.FilePath ((</>), addTrailingPathSeparator)
import System
import Directory
import Data.Tree

target_dirs :: [FilePath]
target_dirs = ["/Users/ent-imac/projects/misc/lang/haskell/", "/Users/ent-imac/projects/moapps_addon/"]

filename :: String
filename = "project.filelist.test"
-- filename = "project.filelist"

main :: IO ()
main = do
  c <- getDirectoryContents "."
  printList c

printList :: [String] -> IO ()
printList ls = pList ls
  where
    pList :: [String] -> IO ()
    pList [] = putStrLn ""
    pList (x:xs) = do
      c <- getCurrentDirectory
      putStrLn $ c ++ "/" ++ x
      pList xs

-- filelist :: FilePath -> [String]
-- filelist path = 

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

-- こっちはうまく行かない気がする
-- *Main> dirTree ".."
-- Node {rootLabel = "..", subForest = []}
dirTree :: FilePath -> IO (Tree FilePath)
dirTree root = unfoldTreeM step (root,root)
    where step (f,c) = do
            fs <- getDirectoryContents f
            ds <- filterM doesDirectoryExist fs
            return (c, [(f </> d, d) | d <- ds, d /= "." && d /= ".."])
