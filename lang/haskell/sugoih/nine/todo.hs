import System.Environment
import System.Directory
import System.IO
import Data.List
import Control.Exception

dispatch :: String -> [String] -> IO ()
dispatch "add" = add
dispatch "view" = view
dispatch "remove" = remove
dispatch _ = error "bad command"

main :: IO ()
main = do
  (command:argList) <- getArgs
  dispatch command argList

add :: [String] -> IO ()
add [fileName, todoItem] = appendFile fileName (todoItem ++ "\n")
add _ = error "bad args"

view :: [String] -> IO ()
view [fileName] = do
  contents <- readFile fileName
  let todoTasks = lines contents
      numberedTasks = zipWith (\n line -> show n ++ " - " ++ line) ([0..] :: [Int]) todoTasks
  putStr $ unlines numberedTasks
view _ = error "bad args"

remove :: [String] -> IO ()
remove [fileName, numberString] = do
  contents <- readFile fileName
  let todoTasks = lines contents
      numberedTasks = zipWith (\n line -> show n ++ " - " ++ line) ([0..] :: [Int]) todoTasks
  putStrLn "There are your TO-DO items:"
  mapM_ putStrLn numberedTasks
  let number = read numberString
      newTodoItems = unlines $ delete (todoTasks !! number) todoTasks
  bracketOnError (openTempFile "." "temp")
    (\ (tempName, tempHandle) -> do
        hClose tempHandle
        removeFile tempName)
    (\ (tempName, tempHandle) -> do
        hPutStr tempHandle newTodoItems
        hClose tempHandle
        removeFile "todo.txt"
        renameFile tempName "todo.txt")
remove _ = error "bad args"
