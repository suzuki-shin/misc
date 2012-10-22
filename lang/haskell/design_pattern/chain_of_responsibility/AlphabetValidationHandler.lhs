\begin{code}
module AlphabetValidationHandler where

import ValidationHandler
import Data.Char

data AlphabetValidationHandler = ValidationHandler a => AlphabetValidationHandler {getString :: String, getNextHandler :: Maybe a}  deriving Show
instance ValidationHandler AlphabetValidationHandler where
  execValidation AlphabetValidationHandler (c:cs) _ = isAlpha c && execValidation cs

\end{code}
<?php
require_once 'ValidationHandler.class.php';
?>
<?php
/**
 * ConcreteHandlerクラスに相当する
 */
class AlphabetValidationHandler extends ValidationHandler {

    /**
     * 自クラスが担当する処理を実行
     */
    protected function execValidation($input) {
        return preg_match('/^[a-z]*$/i', $input);
    }

    /**
     * 処理失敗時のメッセージを取得する
     */
    protected function getErrorMessage() {
        return '半角英字で入力してください';
    }
}
?>