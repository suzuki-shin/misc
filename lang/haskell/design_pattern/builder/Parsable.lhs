\begin{code}
{-# OPTIONS -Wall #-}
module Parsable (Parsable, parse) where

import News

class Parsable a where
  parse :: a -> [News]

\end{code}
// NewsBuilder.class.php
<?php
/**
 * Builderクラスに相当する
 */
interface NewsBuilder {
    public function parse($data);
}
?>