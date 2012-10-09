\begin{code}
{-# LANGUAGE OverloadedStrings #-}

import Data.List
import Text.CSV
import Text.XmlHtml
import qualified Data.ByteString.Char8 as D
import Control.Monad
-- import Control.Monad.IO (liftIO)

class ReaderF a where
  readF :: a -> IO Document

class PrinterD a where
  display :: a -> IO ()

instance PrinterD Document where
  display doc = print "hoge"

data FileReader = CSVFileReader FilePath
                | XMLFileReader FilePath
                deriving (Show)

instance ReaderF FileReader where
--   readF (CSVFileReader file) = do
--     res <- parseCSVFromFile file
--     case res of
--       Left parseError -> error "hoge"
--       Right csv -> return csv
  readF (XMLFileReader file) = do
    res <- readFile file
    case parseXML "xml" (D.pack res) of
--       Left parseError -> return "hoge"
      Right xml -> return xml
      Left err -> error err



data DataPrinter = CSVPrinter Document
                 | XMLPrinter Document
                 deriving (Show)



createReader :: FilePath -> FileReader
createReader file
  | ".csv" `isSuffixOf` file = CSVFileReader file
  | ".xml" `isSuffixOf` file  = XMLFileReader file
  | otherwise = error "hoge"


fileName :: FilePath
fileName = "Music.xml"
-- fileName = "Music.csv"

-- body :: FilePath -> String
-- body file = getBody $ readF (createReader file)
-- body file = getBody $ readF $ CSVFileReader file

-- main :: IO ()
-- main = do
--   c <- readF (createReader fileName)
--   display c

-- hoge = do
--   c <- readF (createReader fileName)
--   render c

\end{code}

<?php
/**
 * 読み込み機能を表すインターフェースクラスです
 */
interface Reader {
    public function read();
    public function display();
}
?>


<?php
    require_once("Reader.class.php");

/**
 * CSVファイルの読み込みを行なうクラスです
 */
class CSVFileReader implements Reader
{
    /**
     * 内容を表示するファイル名
     *
     * @access private
     */
    private $filename;

    /**
     * データを扱うハンドラ名
     *
     * @access private
     */
    private $handler;

    /**
     * コンストラクタ
     *
     * @param string ファイル名
     * @throws Exception
     */
    public function __construct($filename)
    {
        if (!is_readable($filename)) {
            throw new Exception('file "' . $filename . '" is not readable !');
        }
        $this->filename = $filename;
    }

    /**
     * 読み込みを行ないます
     */
    public function read()
    {
        $this->handler = fopen ($this->filename, "r");
    }

    /**
     * 表示を行ないます
     */
    public function display()
    {
        $column = 0;
        $tmp = "";
       while ($data = fgetcsv ($this->handler, 1000, ",")) {
            $num = count ($data);
            for ($c = 0; $c < $num; $c++) {
                if($c == 0) {
                    if($column != 0 && $data[$c] != $tmp) {
                        echo "</ul>";
                    }
                    if($data[$c] != $tmp) {
                        echo "<b>" . $data[$c] . "</b>";
                        echo "<ul>";
                        $tmp = $data[$c];
                    }
                }else {
                    echo "<li>";
                    echo $data[$c];
                    echo "</li>";
                }
            }
            $column++;
        }
        echo "</ul>";
        fclose ($this->handler);
    }
}
?>

<?php
    require_once("Reader.class.php");

/**
 * XMLファイルの読み込みを行なうクラスです
 */
class XMLFileReader implements Reader
{
    /**
     * 内容を表示するファイル名
     *
     * @access private
     */
    private $filename;

    /**
     * データを扱うハンドラ名
     *
     * @access private
     */
    private $handler;

    /**
     * コンストラクタ
     *
     * @param string ファイル名
     * @throws Exception
     */
    public function __construct($filename)
    {
        if (!is_readable($filename)) {
            throw new Exception('file "' . $filename . '" is not readable !');
        }
        $this->filename = $filename;
    }


    /**
     * 読み込みを行ないます
     */
    public function read()
    {
        $this->handler = simplexml_load_file($this->filename);
    }

    /**
     * 文字コードの変換を行います
     */
    private function convert($str) {
        return mb_convert_encoding($str, mb_internal_encoding(), "auto");
    }

    /**
     * 表示を行ないます
     */
    public function display()
    {
        foreach ($this->handler->artist as $artist) {
            echo "<b>" . $this->convert($artist['name']) . "</b>";
            echo "<ul>";
            foreach ($artist->music as $music) {
                echo "<li>";
                echo $this->convert($music['name']);
                echo "</li>";
            }
            echo "</ul>";
        }
    }

}
?>


<?php
require_once('Reader.class.php');
require_once('CSVFileReader.class.php');
require_once('XMLFileReader.class.php');

/**
 * Readerクラスのインスタンス生成を行なうクラスです
 */
class ReaderFactory
{
    /**
     * Readerクラスのインスタンスを生成します
     */
    public function create($filename)
    {
        $reader = $this->createReader($filename);
        return $reader;
    }

    /**
     * Readerクラスのサブクラスを条件判定し、生成します
     */
    private function createReader($filename)
    {
        $poscsv = stripos($filename, '.csv');
        $posxml = stripos($filename, '.xml');

        if($poscsv !== false) {
            $r = new CSVFileReader($filename);
            return $r;
        } else if($posxml !== false) {
            return new XMLFileReader($filename);
        } else {
            die('This filename is not supported : ' . $filename);
        }
    }
}
?>


<?php
require_once('ReaderFactory.class.php');
?>
<html lang="ja">
<head>
<title>作曲家と作品たち</title>
</head>
<body>
<?php
    /**
     * 外部からの入力ファイルです
     */
    $filename = 'Music.xml';

    $factory = new ReaderFactory();
    $data = $factory->create($filename);
    $data->read();
    $data->display();
?>
</body>
</html>
