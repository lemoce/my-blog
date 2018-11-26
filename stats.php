<?php

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}



$ip = $_SERVER['REMOTE_ADDR'];

$ua = "";
if (array_key_exists("HTTP_USER_AGENT", $_SERVER)) {
    $ua = $_SERVER['HTTP_USER_AGENT'];
}

$referer = "";
if (array_key_exists("HTTP_REFERER", $_SERVER)) {
    $referer = $_SERVER['HTTP_REFERER'];
}

$req_date = date("Y-m-d", $_SERVER['REQUEST_TIME']);
$req_time = date("H:i:s", $_SERVER['REQUEST_TIME']);


$sql = "INSERT INTO access_log (host, user_agent, data, hora, url) VALUES ('" . $ip . "', '" . $ua . "','". $req_date ."','". $req_time ."','" . $referer . "')";

$conn->query($sql);

if ($conn) {
    $conn->close();
}

$content = file_get_contents('images/bit.gif');
header('Content-Type: image/gif');
echo $content;

?>
