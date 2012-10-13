\begin{code}

module Item where

data Item = Item {getId :: Int , getName :: String} deriving (Show, Eq, Ord)

\end{code}

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
