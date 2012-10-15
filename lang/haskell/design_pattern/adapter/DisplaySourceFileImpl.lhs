\begin{code}

module DisplaySourceFileImpl (DisplaySource(DisplaySource), display ) where

import DisplaySourceFileClass
import File

data DisplaySource = DisplaySource FilePath deriving Show
instance Display DisplaySource where
  display (DisplaySource file) = showHighlight file

\end{code}
// 継承を使った場合のDisplaySourceFileImpl.class.php
<?php
require_once 'DisplaySourceFile.class.php';
require_once 'ShowFile.class.php';
?>
<?php
/**
 * DisplaySourceFileを実装したクラス
 */
class DisplaySourceFileImpl extends ShowFile implements DisplaySourceFile
{
    /**
     * コンストラクタ
     */
    public function __construct($filename)
    {
        parent::__construct($filename);
    }

    /**
     * 指定されたソースファイルをハイライト表示する
     */
    public function display()
    {
        parent::showHighlight();
    }
}
?>

// 委譲を使った場合のDisplaySourceFileImpl.class.php
<?php
require_once 'DisplaySourceFile.class.php';
require_once 'ShowFile.class.php';
?>
<?php
/**
 * DisplaySourceFileを実装したクラス
 */
class DisplaySourceFileImpl implements DisplaySourceFile
{
    /**
     * ShowFileクラスのインスタンスを保持する
     */
    private $show_file;

    /**
     * コンストラクタ
     */
    public function __construct($filename)
    {
        $this->show_file = new ShowFile($filename);
    }

    /**
     * 指定されたソースファイルをハイライト表示する
     */
    public function display()
    {
        $this->show_file->showHighlight();
    }
}
?>