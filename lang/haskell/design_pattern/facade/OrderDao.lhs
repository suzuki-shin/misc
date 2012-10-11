\begin{code}

module OrderDao (createOrder) where

import qualified Order as O
import qualified Item as I

createOrder :: O.Order -> IO ()
createOrder order = do
  putStrLn "以下の内容で注文データを作成しました";
  putStrLn "<table border=\"1\">";
  putStrLn "<tr>";
  putStrLn "<th>商品番号</th>";
  putStrLn "<th>商品名</th>";
  putStrLn "<th>単価</th>";
  putStrLn "<th>数量</th>";
  putStrLn "<th>金額</th>";
  putStrLn "</tr>";
  printItems (O.getItems order)
  putStrLn "</table>"
  where
    printItems :: [O.OrderItem] -> IO ()
    printItems (oi:ois) = do
      let item = O.getItem oi
          totalPrice = (O.getAmount oi) * (I.getPrice item)
      putStrLn "<tr>"
      putStrLn $ "<td>" ++ show (I.getId item) ++ "</td>"
      putStrLn $ "<td>" ++ show (I.getName item) ++ "</td>"
      putStrLn $ "<td>" ++ show (I.getPrice item) ++ "</td>"
      putStrLn $ "<td>" ++ show (O.getAmount oi) ++ "</td>"
      putStrLn $ "<td>" ++ show totalPrice ++ "</td>"
      putStrLn "</tr>"
      printItems ois
    printItems [] = return ()

\end{code}

// OrderDaoクラス（OrderDao.class.php）
<?php
require_once 'Order.class.php';
?>
<?php
class OrderDao {
    public static function createOrder(Order $order) {
        echo '以下の内容で注文データを作成しました';

        echo '<table border="1">';
        echo '<tr>';
        echo '<th>商品番号</th>';
        echo '<th>商品名</th>';
        echo '<th>単価</th>';
        echo '<th>数量</th>';
        echo '<th>金額</th>';
        echo '</tr>';

        foreach ($order->getItems() as $order_item) {
            echo '<tr>';
            echo '<td>' . $order_item->getItem()->getId() . '</td>';
            echo '<td>' . $order_item->getItem()->getName() . '</td>';
            echo '<td>' . $order_item->getItem()->getPrice() . '</td>';
            echo '<td>' . $order_item->getAmount() . '</td>';
            echo '<td>' . ($order_item->getItem()->getPrice() * $order_item->getAmount()) . '</td>';
            echo '</tr>';
        }
        echo '</table>';
    }
}
?>