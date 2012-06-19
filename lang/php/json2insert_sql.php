<?php
/* var_export(json_decode(fgets(STDIN), true)); */
$data = array_pop(json_decode(fgets(STDIN), true));
print_r($data);

$sql = "INSERT INTO {table} ("
    . implode(',', array_keys($data)) .") VALUES ("
    . implode(',', array_map(function($x){return "'$x'";}, array_values($data))) .");";

print_r($sql);