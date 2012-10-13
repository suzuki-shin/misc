\begin{code}

import Factory
import Dao

itemId = 1
orderId = 3

printItem factory = putStrLn "ID=" ++ show itemId ++ "の商品は「" ++ getName item ++ "」です<br>"
  where
    item = findItemById (createItemDao factory) itemId

printOrder factory = do
  putStrLn "ID=" ++ show orderId ++ "の注文情報は次の通りです。"
  putStrLn "<ul>"
  printOrder' items
  putStrLn "</ul>"
  where
    items = getItems $ findOrderById (createOrderDao factory) orderId
    printOrder' (i:is) = do
      putStrLn "<li>" ++ getName (getObject i) ++ "</li>"
      printOrder' is

main = do
  f <- getLine
  let factory = case f of
        1 -> DbFactory
        2 -> MockFactory
  printItem factory
  printOrder factory


\end{code}

// abstract_factory_client.php
<?php
    if (isset($_POST['factory'])) {
        $factory = $_POST['factory'];

        switch ($factory) {
        case 1:
            include_once 'DbFactory.class.php';
            $factory = new DbFactory();
            break;
        case 2:
            include_once 'MockFactory.class.php';
            $factory = new MockFactory();
            break;
        }

        $item_id = 1;
        $item_dao = $factory->createItemDao();
        $item = $item_dao->findById($item_id);
        echo 'ID=' . $item_id . 'の商品は「' . $item->getName() . '」です<br>';

        $order_id = 3;
        $order_dao = $factory->createOrderDao();
        $order = $order_dao->findById($order_id);
        echo 'ID=' . $order_id . 'の注文情報は次の通りです。';
        echo '<ul>';
        foreach ($order->getItems() as $item) {
            echo '<li>' . $item['object']->getName();
        }
        echo '</ul>';
    }
?>
<hr>
<form action="" method="post">
  <div>
    DaoFactoryの種類：
    <input type="radio" name="factory" value="1">DbFactory
    <input type="radio" name="factory" value="2">MockFactory
  </div>
  <div>
    <input type="submit">
  </div>
</form>