\begin{code}
{-# OPTIONS -Wall #-}
module News (Url, Date, Title, News(News, getTitle, getUrl, getDate))where

type Url = String
type Date = String
type Title = String
data News = News {getTitle :: Title, getUrl :: Url, getDate :: Date}


\end{code}
// News.class.php
<?php
class News {
    private $title;
    private $url;
    private $target_date;

    public function __construct($title, $url, $target_date) {
        $this->title = $title;
        $this->url = $url;
        $this->target_date = $target_date;
    }

    public function getTitle() {
        return $this->title;
    }

    public function getUrl() {
        return $this->url;
    }

    public function getDate() {
        return $this->target_date;
    }
}
?>
