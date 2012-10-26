\begin{code}
import Control.Applicative
import Control.Monad
import Chatroom
import User

main = do
  let sasaki = User "sasaki"
      suzuki = User "suzuki"
      yoshida = User "yoshida"
      kawamura = User "kawamura"
      tajima = User "tajima"
      hagiwara = User "hagiwara"
  room <- foldM login (Chatroom []) [sasaki, suzuki, yoshida, kawamura, tajima]
  sendMessage room sasaki suzuki "来週の予定は"
  sendMessage room suzuki kawamura "ひみつです"
  sendMessage room yoshida hagiwara "元気ですか?"
  sendMessage room tajima sasaki "お邪魔してます"
  sendMessage room kawamura yoshida "私事で恐縮ですが・・・"

\end{code}
// mediator_client.php
<?php
require_once 'Chatroom.class.php';
require_once 'User.class.php';
?>
<?php
    $chatroom = new Chatroom();

    $sasaki = new User('佐々木');
    $suzuki = new User('鈴木');
    $yoshida = new User('吉田');
    $kawamura = new User('川村');
    $tajima = new User('田島');

    $chatroom->login($sasaki);
    $chatroom->login($suzuki);
    $chatroom->login($yoshida);
    $chatroom->login($kawamura);
    $chatroom->login($tajima);

    $sasaki->sendMessage('鈴木', '来週の予定は？') ;
    $suzuki->sendMessage('川村', '秘密です') ;
    $yoshida->sendMessage('萩原', '元気ですか？') ;
    $tajima->sendMessage('佐々木', 'お邪魔してます') ;
    $kawamura->sendMessage('吉田', '私事で恐縮ですが・・・') ;
?>