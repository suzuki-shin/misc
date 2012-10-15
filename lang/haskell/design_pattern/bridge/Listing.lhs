\begin{code}

module Listing (open', read', close') where

import Control.Applicative
import qualified DataSource as DS
import qualified DataSourceClass as DSC

data Listing = ListingFile DS.DataSource deriving Show

open' :: DS.DataSource -> IO Listing
open' dataSource = ListingFile <$> (DS.open' dataSource)
-- open' dataSource = do
--   dataSource' <- DS.open' dataSource
--   return $ ListingFile dataSource'

read' :: Listing -> IO String
read' (ListingFile dataSource) = DS.read' dataSource
-- read' (ListingDb dataSource) = DS.read' dataSource

close' :: Listing -> IO ()
close' (ListingFile dataSource) = DS.close' dataSource
-- close' (ListingDb dataSource) = DS.close' dataSource

\end{code}
<?php
require_once 'DataSource.class.php';

class Listing {
    private $data_source;

    /**
     * コンストラクタ
     * @param $source_name ファイル名
     */
    function __construct($data_source) {
        $this->data_source = $data_source;
    }

    /**
     * データソースを開く
     */
    function open() {
        $this->data_source->open();
    }

    /**
     * データソースからデータを取得する
     * @return array データの配列
     */
    function read() {
        return $this->data_source->read();
    }

    /**
     * データソースを閉じる
     */
    function close() {
        $this->data_source->close();
    }
}
?>