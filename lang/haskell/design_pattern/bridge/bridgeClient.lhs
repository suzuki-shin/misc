\begin{code}

import Control.Applicative
import Control.Exception as E
import Listing as L
import ExtendedListing as EL
import DataSource as DS

main = do
  bracket (L.open' $ DS.FileDataSource "data.txt" Nothing)
    (L.close')
    (\list -> L.read' list >>= putStrLn)
  bracket (EL.open' $ DS.FileDataSource "data.txt" Nothing)
    (EL.close')
    (\list -> EL.readWithEncode list >>= putStrLn)

\end{code}

// bridge_client.php
<?php
require_once 'Listing.class.php';
require_once 'ExtendedListing.class.php';
require_once 'FileDataSource.class.php';
?>
<?php
    /**
     * Listingクラス、ExtendedListingクラスをインスタンス化する。
     * 具体的な処理クラスとして、FileDataSourceクラスを使う。
     * データファイルは、data.txt
     */
    $list1 = new Listing(new FileDataSource('data.txt'));
    $list2 = new ExtendedListing(new FileDataSource('data.txt'));

    try {
        $list1->open();
        $list2->open();
    }
    catch (Exception $e) {
        die($e->getMessage());
    }

    /**
     * 取得したデータの表示（readメソッド）
     */
    $data = $list1->read();
    echo $data;

    /**
     * 取得したデータの表示（readWithEncodeメソッド）
     */
    $data = $list2->readWithEncode();
    echo $data;


    $list1->close();
    $list2->close();
?>