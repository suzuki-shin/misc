{-# OPTIONS_GHC -Wall #-}
module MyTools where

import System.Directory
import System.Cmd
import Control.Applicative
import Data.List
import System.IO (openFile, IOMode(..), hClose, hFileSize, readFile, writeFile, hSetEncoding, hGetContents)
-- import Control.Exception (bracket)
import Codec.Text.IConv
import Data.ByteString.Lazy.Char8 (pack, unpack)
import Codec.Binary.UTF8.String
import qualified Data.ByteString.Lazy.Char8 as BS

-- Stringのencodingを変換する
convertEncoding :: EncodingName -> EncodingName -> String -> String
convertEncoding fromEnc toEnc = decodeString . unpack . convert fromEnc toEnc . pack

-- ファイルのencodingを変換して吐き出し直す
convertFileEnc :: EncodingName -> EncodingName -> FilePath -> FilePath -> IO ()
convertFileEnc fromEnc toEnc inFile outFile = do
  cs <- BS.readFile inFile
  let cs' = convert fromEnc toEnc cs
  BS.writeFile outFile cs'
  return ()

-- ディレクトリパスと拡張子を指定して、当てはまるファイルリストを返す
getFileListByExt :: FilePath -> String -> IO [FilePath]
getFileListByExt dir ext = (fileFilter ext) <$> getDirectoryContents dir
  where
    fileFilter :: String -> [FilePath] -> [FilePath]
    fileFilter ext' = filter (("." ++ ext') `isSuffixOf`)

-- ファイルの一行目を削除する
removeHeader :: FilePath -> FilePath -> IO ()
removeHeader inFile outFile = do
  -- putStrLn inFile
  ls <- lines <$> readFile inFile
  writeFile outFile $ unlines $ tail ls

-- unzipCmd :: FilePath -> IO GHC.IO.Exception.ExitCode
unzipCmd file = system ("unzip " ++ file)
