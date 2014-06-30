{-# LANGUAGE EmptyDataDecls    #-}
{-# LANGUAGE FlexibleContexts  #-}
{-# LANGUAGE GADTs             #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TemplateHaskell   #-}
{-# LANGUAGE TypeFamilies      #-}
{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances      #-}

-- |
-- tsvファイルの中身ををsqliteにINSERTするスクリプト
-- 
-- usage:
-- 1. カラム数をあわせるように設定して (share [mkPersist,,, の部分）
-- 2. コンパイル (ghc tsvToSqlite3)
-- 1. 実行 (cat 2014062*log|./tsvToSqlite3)
-- 

import Data.List.Split
import Control.Applicative

import Database.Persist
import Database.Persist.Sqlite
import Database.Persist.TH

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Tsv
    col0 String
    col1 String
    col2 String
    col3 String
    deriving Show
|]

main :: IO ()
main = do
    d <- map (filter (/= "") . splitOn "\t") <$> lines <$> getContents
    runSqlite "tsv.db" $ do
      runMigration migrateAll
      mapM_ (\[c0,c1,c2,c3] -> insert $ Tsv c0 c1 c2 c3) d
    return ()
