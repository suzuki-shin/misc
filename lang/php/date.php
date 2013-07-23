<?php
date_default_timezone_set('Asia/Tokyo');

$i = 100;
// echo date('Y-m-d 09:50:00',strtotime("+$i seconds"));
echo date('Y-m-d H:i:s',strtotime("+$i seconds"));
echo("\n");
echo date('Y-m-d H:i:s',strtotime("+100 seconds"));
echo("\n");
echo date('Y-m-d H:i:s',strtotime("-1 minutes"));
echo("\n");
echo date('Y-m-d H:i:s',strtotime("-$i minutes"));
exit;

echo date('Y', strtotime('2013-03-12 23:32:20'));
echo date('m', strtotime('2013-03-12 23:32:20'));
echo date('d', strtotime('2013-03-12 23:32:20'));
echo date('H', strtotime('2013-03-12 23:32:20'));
echo date('i', strtotime('2013-03-12 23:32:20'));
echo date('s', strtotime('2013-03-12 23:32:20'));
exit;
/* $time = date('Y-m-d H:i:s'); */
/* $time = '2013-04-30 23:40:09'; */
$time = '2013-04-23 17:54:09';
echo date('Y-m-d 23:59:59', strtotime($time . "+6 days"));
/* echo date('Y-m-d H:i:59', strtotime($time . "+179 minutes")); */
exit;


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
