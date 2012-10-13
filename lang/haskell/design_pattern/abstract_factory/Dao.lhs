\begin{code}

module Dao (ItemDao, OrderDao, findOrderById, findItemById) where

import Control.Applicative
import Data.Maybe
import Order
import Item

class FindableOrder a where
  findOrderById :: a -> Int -> Maybe Order

class FindableItem a where
  findItemById :: a -> Int -> Maybe Item

data OrderDao = DbOrderDao {getOrders :: [Order]}
              | MockOrderDao {getOrders :: [Order]}
              deriving (Show)
instance FindableOrder OrderDao where
  findOrderById (DbOrderDao orders) orderId = undefined
  findOrderById (MockOrderDao orders) orderId = undefined

data ItemDao = DbItemDao {getItems :: [Item]}
              | MockItemDao {getItems :: [Item]}
              deriving (Show)
instance FindableItem ItemDao where
  findItemById (DbItemDao items) itemId = undefined
  findItemById (MockItemDao items) itemId = undefined




\end{code}
// OrderDao.class.php
<?php
interface OrderDao {
    public function findById($order_id);
}
?>

// DbOrderDao.class.php
<?php
require_once 'OrderDao.class.php';
require_once 'Order.class.php';
?>
<?php
class DbOrderDao implements OrderDao {
    private $orders;
    public function __construct(ItemDao $item_dao) {
        $fp = fopen('order_data.txt', 'r');

        /**
         * ヘッダ行を抜く
         */
        $dummy = fgets($fp, 4096);

        $this->orders = array();
        while ($buffer = fgets($fp, 4096)) {
            $order_id = trim(substr($buffer, 0, 10));
            $item_ids = trim(substr($buffer, 10));

            $order = new Order($order_id);
            foreach (split(',', $item_ids) as $item_id) {
                $item = $item_dao->findById($item_id);
                if (!is_null($item)) {
                    $order->addItem($item);
                }
            }
            $this->orders[$order->getId()] = $order;
        }

        fclose($fp);
    }

    public function findById($order_id) {
        if (array_key_exists($order_id, $this->orders)) {
            return $this->orders[$order_id];
        } else {
            return null;
        }
    }
}
?>

// MockOrderDao.class.php
<?php
require_once 'OrderDao.class.php';
require_once 'Order.class.php';
?>
<?php
class MockOrderDao implements OrderDao {
    public function findById($order_id) {
        $order = new Order('999');
        $order->addItem(new Item('99', 'ダミー商品'));
        $order->addItem(new Item('99', 'ダミー商品'));
        $order->addItem(new Item('98', 'テスト商品'));

        return $order;
    }
}
?>

// ItemDao.class.php
<?php
interface ItemDao {
    public function findById($item_id);
}
?>

// DbItemDao.class.php
<?php
require_once 'ItemDao.class.php';
require_once 'Item.class.php';
?>
<?php
class DbItemDao implements ItemDao {
    private $items;
    public function __construct() {
        $fp = fopen('item_data.txt', 'r');

        /**
         * ヘッダ行を抜く
         */
        $dummy = fgets($fp, 4096);

        $this->items = array();
        while ($buffer = fgets($fp, 4096)) {
            $item_id = trim(substr($buffer, 0, 10));
            $item_name = trim(substr($buffer, 10));

            $item = new Item($item_id, $item_name);
            $this->items[$item->getId()] = $item;
        }

        fclose($fp);
    }

    public function findById($item_id) {
        if (array_key_exists($item_id, $this->items)) {
            return $this->items[$item_id];
        } else {
            return null;
        }
    }
}
?>


// MockItemDao.class.php
<?php
require_once 'ItemDao.class.php';
require_once 'Item.class.php';
?>
<?php
class MockItemDao implements ItemDao {
    public function findById($item_id) {
        $item = new Item('99', 'ダミー商品');
        return $item;
    }
}
?>

