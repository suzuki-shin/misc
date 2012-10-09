\begin{code}

module Order (Item(Item, getId, getName, getPrice)) where

data Item = Item {getId :: Int, getName :: String, getPrice :: Int} deriving (Show, Eq)

\end{code}

// Itemクラス（Item.class.php）
<?php
class Item {
    private $id;
    private $name;
    private $price;
    public function __construct($id, $name, $price) {
        $this->id = $id;
        $this->name = $name;
        $this->price = $price;
    }
    public function getId() {
        return $this->id;
    }
    public function getName() {
        return $this->name;
    }
    public function getPrice() {
        return $this->price;
    }
}
?>
