\begin{code}
import UpperCaseText
import ReverseText
import PlainText

main = do
  putStrLn "input text"
  text <- getLine
  putStrLn "select decorator\n1 upper case\n2 reverse\n3 both\n4 plain"
  decoratorNum <- getLine
  putStrLn $ case decoratorNum of
    "1" -> getText (UpperCaseText text)
    "2" -> getText (ReverseText text)
    "3" -> getText $ ReverseText (getText (UpperCaseText text))
    "4" -> getText $ PlainText text

\end{code}
// decorator_client.php

<?php
require_once('UpperCaseText.class.php');
require_once('DoubleByteText.class.php');
require_once('PlainText.class.php');
?>
<?php
    $text = (isset($_POST['text'])? $_POST['text'] : '');
    $decorate = (isset($_POST['decorate'])? $_POST['decorate'] : array());
    if ($text !== '') {
        $text_object = new PlainText();
        $text_object->setText($text);

        foreach ($decorate as $val) {
            switch ($val) {
            case 'double':
                $text_object = new DoubleByteText($text_object);
                break;
            case 'upper':
                $text_object = new UpperCaseText($text_object);
                break;
            }
        }
        echo $text_object->getText() . "<br>";
    }

?>
<hr>
<form action="" method="post">
テキスト：<input type="text" name="text"><br>
装飾：<input type="checkbox" name="decorate[]" value="upper">大文字に変換
<input type="checkbox" name="decorate[]" value="double">2バイト文字に変換
<input type="submit">
</form>

