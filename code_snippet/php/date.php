<?php
date_default_timezone_set('Asia/Tokyo');


echo date('Y-m', strtotime('2010-12-21'));

// 日付比較 strtotime
$d1 = '2012-03-10 18:33:10';
if (strtotime($d1) > strtotime('now')) {echo("$d1は未来");} else {echo("$d1は過去");}

// startからendまでのyyyy-mmのリストを作る
function yyyymm_list($start, $end) {
    $ym_list = array();
    $ym = $start;
    date_default_timezone_set('Asia/Tokyo');
    while (strtotime($ym) <= strtotime($end)) {
        $ym_list[] = $ym;
        $ym = date('Y-m',strtotime($ym ."+1 month")); // 1day前の日時
    }

    return $ym_list;
}
print_r(yyyymm_list('2011-09', '2012-04'));
/*
array(
    2011-09,
    2011-10,
    2011-11,
    2011-12,
    2012-01,
    2012-02,
    2012-03,
    2012-04,
);
*/
