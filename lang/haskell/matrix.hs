{-# OPTIONS -Wall #-}
import Control.Applicative

data State = O | X deriving Show
type Matrix = [[(String, State)]]

main :: IO ()
main = do
   items <- lines <$> getContents
   printMatrix $ matrix items
   return ()

-- | 入力項目のリストに対するO、Xのマトリクスを返す
-- >>> matrix ["hoge","fuga","foo"]
-- [[("hoge",O),("fuga",O),("foo",O)],[("hoge",O),("fuga",O),("foo",X)],[("hoge",O),("fuga",X),("foo",O)],[("hoge",O),("fuga",X),("foo",X)],[("hoge",X),("fuga",O),("foo",O)],[("hoge",X),("fuga",O),("foo",X)],[("hoge",X),("fuga",X),("foo",O)],[("hoge",X),("fuga",X),("foo",X)]]
-- >>> matrix []
-- [[]]
matrix :: [String] -> Matrix
matrix items = mapM (\x -> [fst x, snd x]) $ map (\i -> ((i,O),(i,X))) items

-- | Matrixデータを表形式で出力する
printMatrix :: Matrix -> IO ()
printMatrix mtx = do
  printHeader
  printMatrix' mtx
  where
    printHeader = do
      mapM_ (putStr . (++"\t") . fst) $ head mtx
      putStrLn ""
    printMatrix' (l:ls) = do
      mapM_ (putStr . (++"\t") . show . snd) l
      putStrLn ""
      printMatrix' ls
    printMatrix' [] = return ()
