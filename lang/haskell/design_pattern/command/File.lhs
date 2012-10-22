\begin{code}
{-# OPTIONS -Wall #-}
module File (File(File, getName), decompress, compress, create) where

data File = File {getName :: String} deriving Show

decompress :: File -> IO ()
decompress file = putStrLn $ (getName file) ++ "を展開しました"

compress :: File -> IO ()
compress file = putStrLn $ (getName file) ++ "を圧縮しました"

create :: File -> IO ()
create file = putStrLn $ (getName file) ++ "を作成しました"

\end{code}
// File.class.php
<?php
/**
 * Receiverクラスに相当する
 */
class File {
    private $name;
    public function __construct($name) {
        $this->name = $name;
    }
    public function getName() {
        return $this->name;
    }
    public function decompress() {
        echo $this->name . 'を展開しました<br>';
    }
    public function compress() {
        echo $this->name . 'を圧縮しました<br>';
    }
    public function create() {
        echo $this->name . 'を作成しました<br>';
    }
}
?>