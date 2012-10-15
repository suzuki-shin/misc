\begin{code}

module DataSource (
--     FileDataSource
--   , DbDataSource
    DataSource(FileDataSource, DbDataSource)
  , open'
  , read'
  , close'
  ) where

import System.IO
import Control.Applicative
import DataSourceClass

-- data FileDataSource = FileDataSource FilePath Handle deriving (Show)
-- instance DataSourceClass FileDataSource where
--   open' file = do
--     h <- openFile file ReadMode
--     return $ FileDataSource file h
--   read' (FileDataSource _ h) = hGetContents h
--   close' (FileDataSource _ h) = hClose h

type DbInfo = String
data DataSource = FileDataSource FilePath (Maybe Handle)
                | DbDataSource DbInfo (Maybe Handle)
                deriving (Show)
instance DataSourceClass DataSource where
  open' (FileDataSource file _) = do
    h <- openFile file ReadMode
    return $ FileDataSource file $ Just h
  open' (DbDataSource dbInfo _) = undefined

  read' (FileDataSource _ (Just h)) = hGetContents h
  read' (DbDataSource _ (Just h)) = undefined

  close' (FileDataSource _ (Just h)) = hClose h
  close' (DbDataSource _ (Just h)) = undefined

-- data DbDataSource = DbDataSource DbInfo Handle deriving (Show)
-- instance DataSourceClass DbDataSource where
--   open' dbInfo = do
--     h <-  dbInfo
--     return $ DbDataSource file h
--   read' (DbDataSource _ h) = hGetContents h
--   close' (DbDataSource _ h) = hClose h


\end{code}

// FileDataSource.class.php
<?php
require_once 'DataSource.class.php';
?>
<?php
/**
 * Implementorクラスで定義されている機能を実装する
 * ConcreteImplementorに相当する
 */
class FileDataSource implements DataSource {

    /**
     * ソース名
     */
    private $source_name;

    /**
     * ファイルハンドラ
     */
    private $handler;

    /**
     * コンストラクタ
     * @param $source_name ファイル名
     */
    function __construct($source_name) {
        $this->source_name = $source_name;
    }

    /**
     * データソースを開く
     * @throws Exception
     */
    function open() {
        if (!is_readable($this->source_name)) {
            throw new Exception('データソースが見つかりません');
        }
        $this->handler = fopen($this->source_name, 'r');
        if (!$this->handler) {
            throw new Exception('データソースのオープンに失敗しました');
        }
    }

    /**
     * データソースからデータを取得する
     * @return string データ文字列
     */
    function read() {
        $buffer = array();
        while (!feof($this->handler)) {
            $buffer[] = fgets($this->handler);
        }
        return join($buffer);
    }

    /**
     * データソースを閉じる
     */
    function close() {
        if (!is_null($this->handler)) {
            fclose($this->handler);
        }
    }
}
?>