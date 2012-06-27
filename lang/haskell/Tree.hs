module Main where
import Control.Monad
import Control.Applicative
import System.FilePath ((</>), addTrailingPathSeparator)
import System
import Directory
import Data.Tree
import System.FilePath

target_dirs :: [FilePath]
target_dirs = ["/Users/ent-imac/projects/misc/lang/haskell/", "/Users/ent-imac/projects/moapps_addon/"]

filename :: String
filename = "project.filelist.test"

main :: IO ()
main = do
  args <- getArgs
  let path = args!!0
  putStrDirTree path

putStrDirTree :: FilePath -> IO ()
putStrDirTree path = do
--   putStrLn parent
--   putStrLn path
  t <- tree1 path
  putStrLn $ drawTree t

-- 再帰的にディレクトリツリーを扱う
--
-- http://codereview.stackexchange.com/questions/8431/how-can-i-make-this-recursive-directory-tree-printer-i-wrote-in-haskell-more-idi
--
tree1 :: FilePath -> IO (Tree FilePath)
tree1 fullPath = tree parent path
  where (parent, path) = splitFileName fullPath

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

-- dirTree :: FilePath -> IO (Tree FilePath)
-- dirTree root = unfoldTreeM step (root,root)
--     where step (f,c) = do
--             fs <- getDirectoryContents f
--             ds <- filterM doesDirectoryExist fs
--             return (c, [(f </> d, d) | d <- ds, d /= "." && d /= ".."])
-- こっちはうまく行かない気がする
-- *Main> dirTree ".."
-- Node {rootLabel = "..", subForest = []}
