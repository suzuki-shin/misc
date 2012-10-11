\begin{code}

module OrderManager (
  O.Order,
  O.OrderItem(OrderItem),
  O.addItem,
  O.initOrder,
  ID.findById,
  ID.getInstance,
  order
  ) where

import qualified Order as O
import qualified ItemDao as ID
import qualified OrderDao as OD

order :: O.Order -> IO ()
order o = do
  mapM_ ID.setAside (O.getItems o)
  OD.createOrder o

\end{code}
<?php
require_once 'Order.class.php';
require_once 'ItemDao.class.php';
require_once 'OrderDao.class.php';
?>
<?php
class OrderManager {
    public static function order(Order $order) {
        $item_dao = ItemDao::getInstance();
        foreach ($order->getItems() as $order_item) {
            $item_dao->setAside($order_item);
        }

        OrderDao::createOrder($order);
    }
}
?>
