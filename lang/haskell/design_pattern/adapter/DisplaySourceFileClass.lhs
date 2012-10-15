\begin{code}

module DisplaySourceFileClass (Display, display) where

class Display a where
  display :: a -> IO ()

\end{code}

// DisplaySourceFile.class.php
<?php
interface DisplaySourceFile
{
    /**
     * 指定されたソースファイルをハイライト表示する
     */
    public function display();
}
?>
