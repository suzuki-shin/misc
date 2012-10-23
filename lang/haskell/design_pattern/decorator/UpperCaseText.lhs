\begin{code}
module UpperCaseText (UpperCaseText(UpperCaseText), getText) where
import TextDecorator
import Data.Char

data UpperCaseText = UpperCaseText String  deriving Show
instance TextDecorator UpperCaseText where
  getText (UpperCaseText text) = map toUpper text

\end{code}
// UpperCaseText.class.php
<?php
require_once('TextDecorator.class.php');
?>
<?php
/**
 * TextDecoratorクラスの実装クラスです
 */
class UpperCaseText extends TextDecorator {

    /**
     * インスタンスを生成します
     */
    public function __construct(Text $target) {
        parent::__construct($target);
    }

    /**
     * 半角小文字を半角大文字に変換して返します
     */
    public function getText() {
        $str = parent::getText();
        $str = strtoupper($str);
        return $str;
    }
}
?>

