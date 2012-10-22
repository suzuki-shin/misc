\begin{code}
{-# OPTIONS -Wall #-}
module Command (Command(TouchCommand, CompressCommand, CopyCommand), execute) where

import File

class Executable a where
  execute :: a -> IO ()

data Command = TouchCommand {getFile :: File}
             | CompressCommand {getFile :: File}
             | CopyCommand {getFile :: File}
             deriving Show
instance Executable Command where
  execute (TouchCommand file) = create file
  execute (CompressCommand file) = compress file
  execute (CopyCommand (File fileName)) = create $ File $ "copy_of_" ++ fileName

\end{code}
// Command.class.php
<?php
/**
 * Commandクラスに相当する
 */
interface Command {
    public function execute();
}
?>

// TouchCommand.class.php
<?php
require_once 'Command.class.php';
require_once 'File.class.php';
?>
<?php
/**
 * ConcreteCommandクラスに相当する
 */
class TouchCommand implements Command {
    private $file;
    public function __construct(File $file) {
        $this->file = $file;
    }
    public function execute() {
        $this->file->create();
    }
}
?>

// CompressCommand.class.php
<?php
require_once 'Command.class.php';
require_once 'File.class.php';
?>
<?php
/**
 * ConcreteCommandクラスに相当する
 */
class CompressCommand implements Command {
    private $file;
    public function __construct(File $file) {
        $this->file = $file;
    }
    public function execute() {
        $this->file->compress();
    }
}
?>

// DecompressCommand.class.php
<?php
require_once 'Command.class.php';
require_once 'File.class.php';
?>
<?php
/**
 * ConcreteCommandクラスに相当する
 */
class DecompressCommand implements Command {
    private $file;
    public function __construct(File $file) {
        $this->file = $file;
    }
    public function execute() {
        $this->file->decompress();
    }
}
?>