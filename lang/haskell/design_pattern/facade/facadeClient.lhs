\begin{code}

import OrderManager
import Data.Maybe

main :: IO ()
main = do
  itemDao <- getInstance
  let addItem' :: Int -> Int -> Order -> Order
      addItem' itemId amount order' = addItem order' $ OrderItem (fromJust (findById itemDao itemId)) amount

  -- 注文処理
  order $ addItem' 3 3 $ addItem' 2 1 $ addItem' 1 2 initOrder

\end{code}
<?php
require_once 'Order.class.php';
require_once 'OrderItem.class.php';
require_once 'ItemDao.class.php';
require_once 'OrderManager.class.php';
?>
<?php
    $order = new Order();
    $item_dao = ItemDao::getInstance();

    $order->addItem(new OrderItem($item_dao->findById(1), 2));
    $order->addItem(new OrderItem($item_dao->findById(2), 1));
    $order->addItem(new OrderItem($item_dao->findById(3), 3));

    /**
     * 注文処理はこの1行だけ
     */
    OrderManager::order($order);

?>