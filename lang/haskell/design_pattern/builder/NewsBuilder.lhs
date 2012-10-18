\begin{code}
{-# OPTIONS -Wall #-}
module NewsBuilder (
  NewsBuilder(RssNewsBuilder), parse,
  Url, Date, Title,
  getUrl, getDate, getTitle,
  ) where

import News
import Parsable

-- ダミー
news1 = News "hoge" "hoge.com" "2012-10-10"
news2 = News "hoge1" "hoge1.com" "2012-10-11"
news3 = News "hoge2" "hoge2.com" "2012-10-12"

data NewsBuilder = RssNewsBuilder Url deriving Show
instance Parsable NewsBuilder where
  parse (RssNewsBuilder url) = [ news1, news2, news3 ]

\end{code}

// RssNewsBuilder.class.php
<?php
require_once 'News.class.php';
require_once 'NewsBuilder.class.php';
?>
<?php
/**
 * ConcreteBuilderクラスに相当する
 */
class RssNewsBuilder implements NewsBuilder {
    public function parse($url) {
        $data = simplexml_load_file($url);
        if ($data === false) {
            throw new Exception('read data [' .
                                htmlspecialchars($url, ENT_QUOTES)
                                . '] failed !');
        }

        $list = array();
        foreach ($data->item as $item) {
            $dc = $item->children('http://purl.org/dc/elements/1.1/');
            $list[] = new News($item->title,
                               $item->link,
                               $dc->date);
        }
        return $list;
    }
}
?>
