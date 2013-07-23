<?php
print implode(',', array_map(function($a){return '"'.$a.'"';},$target_affs));


print_r(array_map(function($a,$b){return array($a,$b);}, range(1,5), array('a','b','c','d')));
exit;

echo "[isset]\n";

echo "未定義\n> ";
echo isset($var_0);
echo "\n\n";

$var_1 = 0;
echo "0\n> ";
echo isset($var_1);
echo "\n\n";

$var_2 = null;
echo "null\n> ";
echo isset($var_2);
echo "\n\n";

$var_3 = false;
echo "false\n> ";
echo isset($var_3);
echo "\n\n";

$var_4 = '';
echo "''\n> ";
echo isset($var_4);
echo "\n\n";

$var_5 = array();
echo "array()\n> ";
echo isset($var_5);
echo "\n\n";

echo "[empty]\n";

echo "未定義\n> ";
echo empty($var0);
echo "\n\n";

$var1 = 0;
echo "0\n> ";
echo empty($var1);
echo "\n\n";

$var2 = null;
echo "null\n> ";
echo empty($var2);
echo "\n\n";

$var3 = false;
echo "false\n> ";
echo empty($var3);
echo "\n\n";

$var4 = '';
echo "''\n> ";
echo empty($var4);
echo "\n\n";

$var5 = array();
echo "array()\n> ";
echo empty($var5);
echo "\n\n";

echo "[is_null]\n";

echo "未定義\n> ";
echo is_null($var__0);
echo "\n\n";

$var__1 = 0;
echo "0\n> ";
echo is_null($var__1);
echo "\n\n";

$var__2 = null;
echo "null\n> ";
echo is_null($var__2);
echo "\n\n";

$var__3 = false;
echo "false\n> ";
echo is_null($var__3);
echo "\n\n";

$var__4 = '';
echo "''\n> ";
echo is_null($var__4);
echo "\n\n";

$var__5 = array();
echo "array()\n> ";
echo is_null($var__5);
echo "\n\n";

/*
[isset]
未定義
> 

0
> 1

null
> 

false
> 1

''
> 1

array()
> 1

[empty]
未定義
> 1

0
> 1

null
> 1

false
> 1

''
> 1

array()
> 1

[is_null]
未定義
> 1

0
> 

null
> 1

false
> 

''
> 

array()
> 

*/

exit;

function quicksort($xs) {
    if (count($xs) <= 1) return $list;
    $x = array_shift($xs);
    $lesseq = function()use($xs, $x){return array_filter($xs, function($y){return $y <= $x;});};
    print_r($xs);
    print_r($lesseq);
    $graterthan = function()use($xs, $x){return array_filter($xs, function($y){return $y > $x;});};
    echo $x;
    print_r($graterthan);
    return array_merge(quicksort($lesseq),
                       array($x),
                       quicksort($graterthan));
}
print_r(quicksort(array(5,1,3,8,4,2)));
exit;

function reverse($list) {
    if (count($list) <= 1) return $list;
    $x = array_shift($list);
    $_list = reverse($list);
    $_list[] = $x;
    return $_list;
}
print_r(reverse(array(1,2,3,4,5)));
exit;
