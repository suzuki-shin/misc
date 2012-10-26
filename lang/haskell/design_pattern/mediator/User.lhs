\begin{code}
module User where

data User = User {getName :: String} deriving (Show, Eq)

receiveMessage :: User -> User -> String -> IO ()
receiveMessage fromUser toUser message = putStrLn $ (getName fromUser) ++ "さんから" ++ (getName toUser) ++ "さんへ: " ++ message

\end{code}
// User.class.php
<?php
require_once 'Chatroom.class.php';
?>
<?php
class User {
    private $chatroom;
    private $name;
    public function __construct($name) {
        $this->name = $name;
    }
    public function getName() {
        return $this->name;
    }
    public function setChatroom(Chatroom $value) {
         $this->chatroom = $value;
    }
    public function getChatroom() {
        return $this->chatroom;
    }
    public function sendMessage($to, $message) {
        $this->chatroom->sendMessage($this->name, $to, $message);
    }
    public function receiveMessage($from, $message) {
        printf('<font color="008800">%sさんから%sさんへ</font>： %s<hr>', $from, $this->getName(), $message);
    }
}
?>