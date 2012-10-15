\begin{code}
import DisplaySourceFileImpl

main :: IO ()
main = display (DisplaySource "File.lhs")

\end{code}
<?php
require_once 'DisplaySourceFileImpl.class.php';
?>
<?php
    /**
     * DisplaySourceFileImplクラスをインスタンス化する。
     * 内容を表示するファイルは、「ShowFile.class.php」
     */
    $show_file = new DisplaySourceFileImpl('./ShowFile.class.php');

    /**
     * プレーンテキストとハイライトしたファイル内容をそれぞれ
     * 表示する
     */
    $show_file->display();
?>
