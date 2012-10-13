\begin{code}

module Order where

import qualified Item as I
import qualified Data.Map as Map

data Order = Order {getId :: Int, getItems :: Map.Map I.Item Int} deriving (Show)

addItem :: Order -> I.Item -> Order
addItem order item =
  let id = getId order
      items = getItems order
  in case Map.lookup item (getItems order) of
    Just amount' -> Order id $ Map.insert item (amount'+1) items
    Nothing -> Order id $ Map.insert item 1 items

\end{code}

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
