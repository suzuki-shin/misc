\begin{code}

module Dao (ItemDao(ItemDao, getItems), findById, getInstance, setAside)where

import Data.String.Utils
import Data.Maybe
import qualified Order as O

data ItemDao = ItemDao {getItems :: [O.Item]}

findById :: ItemDao -> Int -> Maybe O.Item
findById itemDao itemId = listToMaybe $ filter (\i -> itemId == O.getId i) (getItems itemDao)

getInstance :: FilePath -> IO ItemDao
getInstance filePath = do
  f <- readFile filePath
  return $ ItemDao (items $ lines f)
  where
    items :: [String] -> [O.Item]
    items (l:ls) = let id = (read $ take 10 l) :: Int
                       name = take 10 (drop 20 l)
                       price = (read $ drop 30 l) :: Int
                   in (O.Item id name price):(items ls)

setAside :: O.OrderItem -> IO ()
setAside orderItem = print $ (O.getName (O.getItem orderItem)) ++ "の引き当てを行いました"

\end{code}

// ItemDaoクラス（ItemDao.class.php）
<?php
require_once 'OrderItem.class.php';
?>
<?php
class ItemDao {
    private static $instance;
    private $items;
    private function __construct() {
        $fp = fopen('item_data.txt', 'r');

        /**
         * ヘッダ行を抜く
         */
        $dummy = fgets($fp, 4096);

        $this->items = array();
        while ($buffer = fgets($fp, 4096)) {
            $item_id = trim(substr($buffer, 0, 10));
            $item_name = trim(substr($buffer, 10, 20));
            $item_price = trim(substr($buffer, 30));

            $item = new Item($item_id, $item_name, $item_price);
            $this->items[$item->getId()] = $item;
        }

        fclose($fp);
    }

    public static function getInstance() {
        if (!isset(self::$instance)) {
            self::$instance = new ItemDao();
        }
        return self::$instance;
    }

    public function findById($item_id) {
        if (array_key_exists($item_id, $this->items)) {
            return $this->items[$item_id];
        } else {
            return null;
        }
    }

    public function setAside(OrderItem $order_item) {
        echo $order_item->getItem()->getName() . 'の在庫引当をおこないました<br>';
    }
}
?>