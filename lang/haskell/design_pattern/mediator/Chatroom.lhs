\begin{code}
module Chatroom where
import Data.List
import User

data Chatroom = Chatroom {getUsers :: [User]} deriving Show

login :: Chatroom -> User -> IO Chatroom
login room user = do
  putStrLn $ (getName user) ++ "さんが入室しました"
  return $ Chatroom (user:(getUsers room))

sendMessage :: Chatroom -> User -> User -> String -> IO ()
sendMessage room fromUser toUser message = do
  case toUser `isInRoom` room of
    True -> receiveMessage toUser fromUser message
    False -> putStrLn $ (getName toUser) ++ "さんは入室していないようです"
  where
    isInRoom :: User -> Chatroom -> Bool
    isInRoom user room' = user `elem` (getUsers room')

\end{code}
// Chatroom.class.php
<?php
require_once 'User.class.php';
?>
<?php
class Chatroom {
    private $users = array();
    public function login(User $user) {
        $user->setChatroom($this);
        if (!array_key_exists($user->getName(), $this->users)) {
            $this->users[$user->getName()] = $user;
            printf('<font color="#0000dd">%sさんが入室しました</font><hr>', $user->getName());
        }
    }
    public function sendMessage($from, $to, $message) {
        if (array_key_exists($to, $this->users)) {
            $this->users[$to]->receiveMessage($from, $message);
        } else {
            printf('<font color="#dd0000">%sさんは入室していないようです</font><hr>', $to);
        }
    }
}
?>
