\begin{code}

module DaoFactory where

import ItemDao
import OrderDao

class DaoFactory a where
  createItemDao :: a -> ItemDao
  createOrderDao :: a -> OrderDao

\end{code}

// DaoFactory.class.php
<?php
interface DaoFactory {
    public function createItemDao();
    public function createOrderDao();
}
?>
