\begin{code}

import SingletonSample

main = do
  let instance1 = getInstance
      instance2 = getInstance


\end{code}

// singleton_client.class.php
<?php
require_once 'SingletonSample.class.php';
?>
<?php
    /**
     * インスタンスを2つ取得する
     */
    $instance1 = SingletonSample::getInstance();
    sleep(1);
    $instance2 = SingletonSample::getInstance();

    echo '<hr>';

    /**
     * 2つのインスタンスが同一IDかどうかを確認する
     */
    echo 'instance ID : ' . $instance1->getID() . '<br>';
    echo '$instance1->getID() === $instance2->getID() : ' . ($instance1->getID() === $instance2->getID() ? 'true' : 'false');
    echo '<hr>';

    /**
     * 2つのインスタンスが同一かどうかを確認する
     */
    echo '$instance1 === $instance2 : ' . ($instance1 === $instance2 ? 'true' : 'false');
    echo '<hr>';

    /**
     * 複製できないことを確認する
     */
    $instance1_clone = clone $instance1;

?>
