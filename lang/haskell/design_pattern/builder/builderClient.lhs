\begin{code}
{-# OPTIONS -Wall #-}
import NewsDirector
import NewsBuilder

url :: Url
url = "http://www.php.net/news.rss"

main = do
  display $ getNews $ NewsDirector (RssNewsBuilder url)
    where
      display :: [String] -> IO ()
      display (n:ns) = do
        putStrLn n
        putStr $ "<li>" ++ (getDate n) ++ "<a href=" ++ (getUrl n) ++ ">" ++ (getTitle n) ++ "</a></li>"
--         display ns
--         return ()

\end{code}
// builder_client.php
<?php
require_once 'NewsDirector.class.php';
require_once 'RssNewsBuilder.class.php';
?>
<?php
    $builder = new RssNewsBuilder();
    $url = 'http://www.php.net/news.rss';

    $director = new NewsDirector($builder, $url);
    foreach ($director->getNews() as $article) {
        printf('<li>[%s] <a href="%s">%s</a></li>',
               $article->getDate(), $article->getUrl(), $article->getTitle());
    }
?>