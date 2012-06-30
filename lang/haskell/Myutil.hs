module Myutil where

import Data.List

-- ghciとかで c <- readFile "psql.txt"やって
-- readPsqlLiteral cってやると
readPsqlLiteral psqlLiteral = alist
  where d = filter (not . ("-" `isPrefixOf`)) $ lines psqlLiteral
        p = map (break ('|' ==)) d
        alist = map (\(a,b) -> (filter (/=' ') a, filter (/='|') b)) p
