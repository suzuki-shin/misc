\begin{code}

module OrderDao where

import Order

class OrderDao a where
  findOrderDaoById :: a -> Int -> Maybe Order

\end{code}
// OrderDao.class.php
<?php
interface OrderDao {
    public function findById($order_id);
}
?>
