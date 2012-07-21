<?php
function psql2array($input) {
    $data = array();
    $d    = array();
    foreach ($input as $line) {
        if (strlen($line) === 0 || substr($line, 0, 1) === '-') {
            if (count($d) !== 0) $data[] = $d;
            $d = array();
        } elseif ($m = explode('|', $line)) {
            $key = trim($m[0]);
            $values = array_map(trim, array_slice($m, 1));
            $d[$key] = $values;
        } else {
        }
    }
    if (count($d) !== 0) $data[] = $d;

    return $data;
}
