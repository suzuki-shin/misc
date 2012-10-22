\begin{code}
{-# OPTIONS -Wall #-}

-- import MaxLengthValidationHandler
-- import NotNullValidationHandler
import Control.Monad

data ValidationHandler = AlphabetValidationHandler
                       | NumberValidationHandler
                       | NotNullValidationHandler
                       | MaxLengthValidationHandler
                       deriving Show

-- instance Monad (Either l r) where
--   return (Either l r) = Right r
--   Left l >>= f = Left l
--   Right r >>= f = Right (f r)

validates :: [ValidationHandler] -> String -> Either String ()
validates [] _ = Right ()
validates (v:vs) input = do
  _ <- validate v input
  validates vs input

validate :: ValidationHandler -> String -> Either String ()
validate AlphabetValidationHandler "" = Right ()
validate AlphabetValidationHandler input = Left "AlphabetValidationHandler"
validate NumberValidationHandler "" = Right ()
validate NumberValidationHandler input = Left "NumberValidationHandler"
validate NotNullValidationHandler "" = Right ()
validate NotNullValidationHandler input = Left "NotNullValidationHandler"
validate MaxLengthValidationHandler "" = Right ()
validate MaxLengthValidationHandler input = Left "MaxLengthValidationHandler"

main = do
  input <- getLine
  print $ validates [
          AlphabetValidationHandler
        , NumberValidationHandler
        , NotNullValidationHandler
        , MaxLengthValidationHandler
        ] input
    
  


\end{code}
<?php
require_once 'MaxLengthValidationHandler.class.php';
require_once 'NotNullValidationHandler.class.php';
?>
<?php
    if (isset($_POST['validate_type']) && isset($_POST['input'])) {
        $validate_type = $_POST['validate_type'];
        $input = $_POST['input'];

        /**
         * チェーンの作成
         * validate_typeの値によってチェーンを動的に変更
         */
        $not_null_handler = new NotNullValidationHandler();
        $length_handler = new MaxLengthValidationHandler(8);

        $option_handler = null;
        switch ($validate_type) {
        case 1:
            include_once 'AlphabetValidationHandler.class.php';
            $option_handler = new AlphabetValidationHandler();
            break;
        case 2:
            include_once 'NumberValidationHandler.class.php';
            $option_handler = new NumberValidationHandler();
            break;
        }

        if (!is_null($option_handler)) {
            $length_handler->setHandler($option_handler);
        }
        $handler = $not_null_handler->setHandler($length_handler);

        /**
         * 処理実行と結果メッセージの表示
         */
        $result = $handler->validate($_POST['input']);
        if ($result === false) {
            echo '検証できませんでした';
        } else if (is_string($result) && $result !== '') {
            echo '<p style="color: #dd0000;">' . $result . '</p>';
        } else {
            echo '<p style="color: #008800;">OK</p>';
        }
    }
?>
<form action="" method="post">
  <div>
    値：<input type="text" name="input">
  </div>
  <div>
    検証内容：<select name="validate_type">
    <option value="0">任意</option>
    <option value="1">半角英字で入力されているか</option>
    <option value="2">半角数字で入力されているか</option>
    </select>
  </div>
  <div>
    <input type="submit">
  </div>
</form>