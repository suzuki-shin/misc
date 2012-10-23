\begin{code}
module PlainText (PlainText(PlainText), getText) where
import TextDecorator

data PlainText = PlainText String deriving Show
instance TextDecorator PlainText where
  getText (PlainText text) = text

\end{code}
// PlainText.class.php
<?php
require_once('Text.class.php');
?>
<?php
/**
 * 編集前のテキストを表すクラスです
 */
class PlainText implements Text {

    /**
     * インスタンスが保持する文字列です
     */
    private $textString = null;

    /**
     * インスタンスが保持する文字列を返します
     */
    public function getText() {
        return $this->textString;
    }

    /**
     * インスタンスに文字列をセットします
     */
    public function setText($str) {
        $this->textString = $str;
    }
}
?>