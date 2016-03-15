<?php

function randstr($length) {
    return substr(md5(num_rand($length)), mt_rand(0, 32 - $length), $length);
}

function num_rand($length) {
    mt_srand((double) microtime() * 1000000);
    $randVal = mt_rand(1, 9);
    for ($i = 1; $i < $length; $i++) {
        $randVal .= mt_rand(0, 9);
    }
    return $randVal;
}

$password = 'huakai123abc!@#';
// $password = randstr(10);  // by diwen
$conn = new mysqli('127.0.0.1', 'root', '');
if(mysqli_connect_errno()){
    echo "mysqli error: ".mysqli_connect_error();
    exit();
}

$conn->select_db('mysql');

// test code
// $result = $conn->query( 'show tables' );
// while ($row = $result->fetch_row()) {
//     var_dump($row);
// }

$conn->query("SET character_set_connection=utf8,character_set_results=utf8,character_set_client=binary");
$conn->query("set password for 'root'@'localhost' = PASSWORD('{$password}')");
$conn->query("delete from user where user = '' or password = ''");
$conn->query("flush privileges");

$conn->close();

echo "Init mysql password successfully, pwd=".$password."\n\n";
