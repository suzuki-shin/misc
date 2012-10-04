\begin{code}

fileName = "Music.xml"

-- main :: IO ()
-- main = display $ readF fileName


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
