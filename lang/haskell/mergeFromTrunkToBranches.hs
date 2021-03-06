{-# OPTIONS_GHC -Wall #-}
import System.Process (readProcess)
import System.FilePath ((</>))
import System.Directory
-- import System.Posix.Files
import System.Environment (getArgs)
import Control.Applicative ((<$>))
import Control.Monad (forM)
import Data.List (intersperse)

{-
    仕事用
    trunkからbranchesの下の各プロジェクトのbranchにマージするスクリプト
    --- 現状はコンフリクトした場合に対応してない ---
    $ mergeFromTrunkToBranches "https://example.jp/hoge" hoge.config
-}

tmpDirPath :: FilePath
tmpDirPath = "__tmp_for_merge"

svnPath :: FilePath
svnPath = "/usr/local/bin/svn"

rmPath :: FilePath
rmPath = "/bin/rm"

main :: IO ()
main = do
  (rootUrl:targetBranchesFile:_) <- getArgs
  putStrLn "[start]"

  targetBranches <- lines <$> readFile targetBranchesFile
  putStrLn $ "target branches are " ++ (concat $ intersperse ", " targetBranches)
  putStrLn "input revs"
  targetRevs <- getLine

  let (br:brs) = targetBranches
  svnCo (branchUrl rootUrl br) tmpDirPath
  setCurrentDirectory tmpDirPath

  mergeFromTrunk rootUrl targetRevs

  forM brs $ \b -> do
    svnSwitch (branchUrl rootUrl b)
    mergeFromTrunk rootUrl targetRevs

  setCurrentDirectory ".."
  rmDir tmpDirPath

  putStrLn "[finish]"

branchUrl :: FilePath -> String -> FilePath
branchUrl rootUrl name = rootUrl </> "branches" </> name

trunkUrl :: FilePath -> FilePath
trunkUrl rootUrl = rootUrl </> "trunk"

mergeFromTrunk :: FilePath -> String -> IO ()
mergeFromTrunk rootUrl revs = do
  svnMerge (trunkUrl rootUrl) revs
  svnDi
  putStrLn "CHECK IN OK? [y/N]"
  ans <- getLine
  if ans == "y"
    then do
      svnCi "[merge] from trunk"
    else
      putStrLn "ABORTED."

rmDir :: FilePath -> IO ()
rmDir dir = do
  putStrLn $ concat $ intersperse " " (rmPath : ["-rf", dir])
  s <- readProcess rmPath ["-rf", dir] []
  putStrLn s

svnCo :: FilePath -> FilePath -> IO ()
svnCo repoUrl targetDir = do
  putStrLn $ concat $ intersperse " " (svnPath : ["co", repoUrl, targetDir])
  s <- readProcess svnPath ["co", repoUrl, targetDir] []
  putStrLn s

svnMerge :: FilePath -> String -> IO ()
svnMerge fromRepoUrl targetRevs = do
  putStrLn $ concat $ intersperse " " (svnPath : ["merge","-c " ++ targetRevs, fromRepoUrl])
  s <- readProcess svnPath ["merge","-c " ++ targetRevs, fromRepoUrl] []
  putStrLn s

svnDi :: IO ()
svnDi = do
  putStrLn $ concat $ intersperse " " (svnPath : ["di"])
  s <- readProcess svnPath ["di"] []
  putStrLn s

svnCi :: String -> IO ()
svnCi message = do
  putStrLn $ concat $ intersperse " " (svnPath : ["ci", "-m\"" ++ message ++ "\""])
  s <- readProcess svnPath ["ci", "-m\"" ++ message ++ "\""] []
  putStrLn s

svnSwitch :: FilePath -> IO ()
svnSwitch url = do
  putStrLn $ concat $ intersperse " " (svnPath : ["switch", url])
  s <- readProcess svnPath ["switch", url] []
  putStrLn s
