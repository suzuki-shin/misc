\begin{code}

module Order (
  OrderItem(OrderItem, getItem, getAmount),
  Order(getItems),
  addItem,
  initOrder
  ) where

import qualified Item as I

data OrderItem = OrderItem {getItem :: I.Item, getAmount :: Int} deriving (Show, Eq)
data Order = Order {getItems :: [OrderItem]} deriving (Show, Eq)
initOrder :: Order
initOrder = Order []

addItem :: Order -> OrderItem -> Order
addItem order' orderItem = Order (orderItem:(getItems order'))

\end{code}

// OrderItemクラス（OrderItem.class.php）
<?php
require_once 'Item.class.php';
?>
<?php
class OrderItem {
    private $item;
    private $amount;
    public function __construct(Item $item, $amount) {
        $this->item = $item;
        $this->amount = $amount;
    }
    public function getItem() {
        return $this->item;
    }
    public function getAmount() {
        return $this->amount;
    }
}
?>

// Orderクラス（Order.class.php）
<?php
require_once 'OrderItem.class.php';
?>
<?php
class Order {
    private $items;
    public function __construct() {
        $this->items = array();
    }
    public function addItem(OrderItem $order_item) {
        $this->items[$order_item->getItem()->getId()] = $order_item;
    }
    public function getItems() {
        return $this->items;
    }
}
?>