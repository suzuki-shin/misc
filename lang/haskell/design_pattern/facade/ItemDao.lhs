\begin{code}

module ItemDao (findById, getInstance, setAside)where

import Data.String.Utils
import Data.Maybe
import qualified Data.ByteString.Char8 as B
import qualified Item as I
import qualified Order as O

data ItemDao = ItemDao {getItems :: [I.Item]}

findById :: ItemDao -> Int -> Maybe I.Item
findById itemDao itemId = listToMaybe $ filter (\i -> itemId == I.getId i) (getItems itemDao)

getInstance :: IO ItemDao
getInstance  = do
  f <- B.readFile "item_data.txt"
  return $ ItemDao (items $ tail $ B.lines f)
  where
    items :: [B.ByteString] -> [I.Item]
    items (l:ls) = let id = (read $ strip $ B.unpack $ B.take 10 l) :: Int
                       name = strip $ B.unpack $ B.take 10 (B.drop 20 l)
                       price = (read $ strip $ B.unpack $ B.drop 30 l) :: Int
                   in (I.Item id name price):(items ls)
    items [] = []

setAside :: O.OrderItem -> IO ()
setAside orderItem = print $ (I.getName (O.getItem orderItem)) ++ "の引き当てを行いました"

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