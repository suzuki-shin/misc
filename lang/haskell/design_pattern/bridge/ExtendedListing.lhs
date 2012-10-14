\begin{code}

module ExtendedListing (open', readWithEncode, close') where

import Control.Applicative
import qualified DataSource as DS
import qualified DataSourceClass as DSC

data ExtendedListing = ExtendedListing DS.DataSource deriving Show

open' :: DS.DataSource -> IO ExtendedListing
open' dataSource = ExtendedListing <$> (DS.open' dataSource)

readWithEncode :: ExtendedListing -> IO String
readWithEncode (ExtendedListing dataSource) = htmlspecialchars <$> DS.read' dataSource

close' :: ExtendedListing -> IO ()
close' (ExtendedListing dataSource) = DS.close' dataSource

htmlspecialchars :: String -> String
htmlspecialchars = id           -- 仮

\end{code}

// ExtendedListing.class.php
<?php
require_once 'Listing.class.php';
?>
<?php
/**
 * Listingクラスで提供されている機能を拡張する
 * RefinedAbstractionに相当する
 */
class ExtendedListing extends Listing {

    /**
     * コンストラクタ
     * @param $source_name ファイル名
     */
    function __construct($data_source) {
        parent::__construct($data_source);
    }

    /**
     * データを読み込む際、データ中の特殊文字を変換する
     * @return 変換されたデータ
     */
    function readWithEncode() {
        return htmlspecialchars($this->read(), ENT_QUOTES);
    }

}
?>