\begin{code}

module DaoFactory where

class DaoFactory a where
  createItemDao :: a -> ItemDao
  createOrderDao :: a -> OrderDao

data Factory = DbFactory FilePath | MockFactory deriving (Show)
instance DaoFactory Factory where
  createItemDao DbFactory = undefined
  createItemDao MockFactory = undefined
  
  createOrderDao DbFactory = undefined
  createOrderDao MockFactory = undefined

class ItemDao a where
  findItemDaoById :: a -> Int -> Maybe Item

class OrderDao a where
  findOrderDaoById :: a -> Int -> Maybe Order

data DbItemDao = DbItemDao {getItems :: [Item]} deriving (Show)
instance ItemDao DbItemDao where
  findItemDaoById dbItemDao itemId = listToMaybe $ filter (\i -> getId i == itemId) $ getItems dbItemDao

data DbOrderDao = DbOrderDao {getOrders :: [Order]} deriving (Show)
instance OrderDao DbOrderDao where
  findOrderDaoById dbOrderDao orderId = listToMaybe $ filter (\o -> getId o == orderId) $ getOrders dbOrderDao

data Item = Item {getId :: Int , getName :: String} deriving (Show)
data Order = Order {getId :: Int, getItems :: [Item]} deriving (Show)



\end{code}

// DaoFactory.class.php
<?php
interface DaoFactory {
    public function createItemDao();
    public function createOrderDao();
}
?>

// DbFactory.class.php
<?php
require_once 'DaoFactory.class.php';
require_once 'DbItemDao.class.php';
require_once 'DbOrderDao.class.php';
?>
<?php
class DbFactory implements DaoFactory {
    public function createItemDao() {
        return new DbItemDao();
    }
    public function createOrderDao() {
        return new DbOrderDao($this->createItemDao());
    }
}
?>

// MockFactory.class.php
<?php
require_once 'DaoFactory.class.php';
require_once 'MockItemDao.class.php';
require_once 'MockOrderDao.class.php';
?>
<?php
class MockFactory implements DaoFactory {
    public function createItemDao() {
        return new MockItemDao();
    }
    public function createOrderDao() {
        return new MockOrderDao();
    }
}
?>

// ItemDao.class.php
<?php
interface ItemDao {
    public function findById($item_id);
}
?>

// OrderDao.class.php
<?php
interface OrderDao {
    public function findById($order_id);
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

// Item.class.php
<?php
class Item {
    private $id;
    private $name;
    public function __construct($id, $name) {
        $this->id = $id;
        $this->name = $name;
    }
    public function getId() {
        return $this->id;
    }
    public function getName() {
        return $this->name;
    }
}
?>

// Order.class.php

<?php
class Order {
    private $id;
    private $items;
    public function __construct($id) {
        $this->id = $id;
        $this->items = array();
    }
    public function addItem(Item $item) {
        $id = $item->getId();
        if (!array_key_exists($id, $this->items)) {
            $this->items[$id]['object'] = $item;
            $this->items[$id]['amount'] = 0;
        }
        $this->items[$id]['amount']++;
    }
    public function getItems() {
        return $this->items;
    }
    public function getId() {
        return $this->id;
    }
}
?>

// 