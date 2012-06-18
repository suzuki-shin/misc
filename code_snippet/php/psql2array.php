<?php
/*
-[ RECORD 1 ]-----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------
id                      | 1700
measure_action_id       | 974
affiliatekey            | rhS5PCW6ZZngrp2yctJK
uid                     | 8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g
user_agent              | Mozilla/5.0 (Linux; U; Android 2.3.5; ja-jp; N-01D Build/A1002701) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1
measure_media_config_id | 3
measure_point_config_id | 1
params                  | {"UA":"Mozilla\/5.0 (Linux; U; Android 2.3.5; ja-jp; N-01D Build\/A1002701) AppleWebKit\/533.1 (KHTML, like Gecko) Version\/4.0 Mobile Safari\/533.1","med
ia_code":"16db2e08","uid":"8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g","sp_uk":"8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g","page_name":
"http:\/\/decupdx.jp\/docomo_landing_1000_1.php?mcd=16db2e08","id":"120528X5zuqY"}
item                    | デカップDX1000
free1                   | 
free2                   | 
free3                   | 
status                  | 10
mukouflg                | f
notes                   | 
created                 | 2012-05-28 20:49:26.122624
modified                | 2012-05-28 20:49:26.122624
-[ RECORD 2 ]-----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------
id                      | 1701
measure_action_id       | 974
affiliatekey            | rhS5PCW6ZZngrp2yctJK
uid                     | 8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g
user_agent              | Mozilla/5.0 (Linux; U; Android 2.3.5; ja-jp; N-01D Build/A1002701) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1
measure_media_config_id | 3
measure_point_config_id | 1
params                  | {"UA":"Mozilla\/5.0 (Linux; U; Android 2.3.5; ja-jp; N-01D Build\/A1002701) AppleWebKit\/533.1 (KHTML, like Gecko) Version\/4.0 Mobile Safari\/533.1","med
ia_code":"16db2e08","uid":"8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g","sp_uk":"8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g","page_name":
"http:\/\/decupdx.jp\/docomo_landing_1000_1.php?mcd=16db2e08","id":"120528X5zuqY"}
item                    | デカップDX500
free1                   | 
free2                   | 
free3                   | 
status                  | 10
mukouflg                | f
notes                   | 
created                 | 2012-05-28 20:51:28.976928
modified                | 2012-05-28 20:51:28.976928
-[ RECORD 3 ]-----------+-----------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------
id                      | 1702
measure_action_id       | 974
affiliatekey            | rhS5PCW6ZZngrp2yctJK
uid                     | 8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g
user_agent              | Mozilla/5.0 (Linux; U; Android 2.3.5; ja-jp; N-01D Build/A1002701) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1
measure_media_config_id | 3
measure_point_config_id | 1
params                  | {"UA":"Mozilla\/5.0 (Linux; U; Android 2.3.5; ja-jp; N-01D Build\/A1002701) AppleWebKit\/533.1 (KHTML, like Gecko) Version\/4.0 Mobile Safari\/533.1","med
ia_code":"16db2e08","uid":"8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g","sp_uk":"8z5MWmy5NhGObpVfeyXwfNlQfBrq5EnF4RntH1NNVqDKYtjHe0ANrnHjgDkyZN4g","page_name":
"http:\/\/decupdx.jp\/docomo_landing_1000_1.php?mcd=16db2e08","id":"120528X5zuqY"}
item                    | デカップDX1000
free1                   | 
free2                   | 
free3                   | 
status                  | 10
mukouflg                | f
notes                   | 
created                 | 2012-05-28 20:52:36.364956
modified                | 2012-05-28 20:52:36.364956

ap00084=> 

みたいなデータ(psqlの\xで表示したデータ)を標準入力から受け取り、phpのarray表現で出力する

*/

function psql2array($input) {
    $data = array();
    $d    = array();
    foreach ($input as $line) {
        if (strlen($line) === 0 || substr($line, 0, 1) === '-') {
            if (count($d) !== 0) $data[] = $d;
            $d = array();
        } elseif (preg_match('/^\s*(\w+)\s*\|\s*(\S+.*)?\s*$/', $line, $m)) {
            $d[$m[1]] = $m[2] ?: '';
        } else {
        }
    }
    if (count($d) !== 0) $data[] = $d;

    return $data;
}

var_export(psql2array(file('php://stdin')));
