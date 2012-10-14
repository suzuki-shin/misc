\begin{code}

module DataSourceClass where

import System.IO

class DataSourceClass a where
  open' :: a -> IO a
  read' :: a -> IO String
  close' :: a -> IO ()

\end{code}

// DataSource.class.php
<?php
/**
 * Implementorに相当する
 * このサンプルでは、インターフェースとして実装
 */
interface DataSource {
    public function open();
    public function read();
    public function close();
}
?>