\begin{code}
-- phpのほうのAbstractDisplayクラス対応
class Show a => Display a where
  header :: a -> String
  body :: a -> [String]
  footer :: a -> String

  display :: a -> IO ()
  display a = do
    putStrLn $ header a
    mapM_ putStrLn $ body a
    putStrLn $ footer a

-- phpのほうのListDisplayクラスに対応
data List_ = List_ [String] deriving (Show)
instance Display List_ where
  header _ = "<dl>"
  body (List_ xs) = map toListHtml $ zip [1..] xs
    where
      toListHtml (n, x) = "<dt>Item " ++ show n ++ "</dt><dd>" ++ x ++ "</dd>"
  footer _ = "</dl>"

-- phpのほうのTableDisplayクラスに対応
data Table_ = Table_ [String] deriving (Show)
instance Display Table_ where
  header _ = "<table border=\"1\" cellpadding=\"2\" cellspacing=\"2\">"
  body (Table_ xs) = map toTableHtml $ zip [1..] xs
    where
      toTableHtml (n, x) = "<tr><th>" ++ show n ++ "</th><td>" ++ x ++ "</td></tr>"
  footer _ = "</table>"


lis :: [String]
lis = ["Design Pattern", "Gang of Four", "Template Method Sample1", "Template Method Sample2"]

main :: IO ()
main = do
  display $ List_ lis
  putStrLn "<hr>"
  display $ Table_ lis

\end{code}

<?php
/**
 * AbstractClassクラスに相当する
 */
abstract class AbstractDisplay {

    /**
     * 表示するデータ
     */
    private $data;

    /**
     * コンストラクタ
     * @param mixed 表示するデータ
     */
    public function __construct($data) {
        if (!is_array($data)) {
            $data = array($data);
        }
        $this->data = $data;
    }

    /**
     * template methodに相当する
     */
    public function display() {
        $this->displayHeader();
        $this->displayBody();
        $this->displayFooter();
    }

    /**
     * データを取得する
     */
    public function getData() {
        return $this->data;
    }

    /**
     * ヘッダを表示する
     * サブクラスに実装を任せる抽象メソッド
     */
    protected abstract function displayHeader();

    /**
     * ボディ（クライアントから渡された内容）を表示する
     * サブクラスに実装を任せる抽象メソッド
     */
    protected abstract function displayBody();

    /**
     * フッタを表示する
     * サブクラスに実装を任せる抽象メソッド
     */
    protected abstract function displayFooter();

}
?>


<?php
require_once 'AbstractDisplay.class.php';
?>
<?php
/**
 * ConcreteClassクラスに相当する
 */
class ListDisplay extends AbstractDisplay {

    /**
     * ヘッダを表示する
     */
    protected function displayHeader() {
        echo '<dl>';
    }

    /**
     * ボディ（クライアントから渡された内容）を表示する
     */
    protected function displayBody() {
        foreach ($this->getData() as $key => $value) {
            echo '<dt>Item ' . $key . '</dt>';
            echo '<dd>' . $value . '</dd>';
        }
    }

    /**
     * フッタを表示する
     */
    protected function displayFooter() {
        echo '</dl>';
    }
}
?>


<?php
require_once 'AbstractDisplay.class.php';
?>
<?php
/**
 * ConcreteClassクラスに相当する
 */
class TableDisplay extends AbstractDisplay {

    /**
     * ヘッダを表示する
     */
    protected function displayHeader() {
        echo '<table border="1" cellpadding="2" cellspacing="2">';
    }

    /**
     * ボディ（クライアントから渡された内容）を表示する
     */
    protected function displayBody() {
        foreach ($this->getData() as $key => $value) {
            echo '<tr>';
            echo '<th>' . $key . '</th>';
            echo '<td>' . $value . '</td>';
            echo '</tr>';
        }
    }

    /**
     * フッタを表示する
     */
    protected function displayFooter() {
        echo '</table>';
    }
}
?>

<?php
require_once 'ListDisplay.class.php';
require_once 'TableDisplay.class.php';
?>
<?php
    $data = array('Design Pattern',
                  'Gang of Four',
                  'Template Method Sample1',
                  'Template Method Sample2');

    $display1 = new ListDisplay($data);
    $display2 = new TableDisplay($data);

    $display1->display();
    echo '<hr>';
    $display2->display();
?>
