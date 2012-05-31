<?php
function psql2array($input) {
 var_dump($input);
    $data = array();
    $d    = array();
    foreach ($input as $line) {
/*     foreach (explode("\n", $input) as $line) { */
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
