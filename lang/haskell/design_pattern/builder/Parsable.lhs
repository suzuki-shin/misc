\begin{code}
{-# OPTIONS -Wall #-}
module Parsable (Parsable, parse) where

class Parsable a where
  parse :: a -> [b]

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