<?php
include_once "Sender.php";
include_once "Requests/GetAuth_Telegram.php";

$tid = $_GET['id'];
$hash = $_GET['hash'];

$hashChecked = hash('sha256', "$tid+randomsalt");

if ($hashChecked == $hash) {
    echo (new \Actions\Sender(new \Actions\GetAuth_Telegram($tid)))->ToJson();
    header("Location: https://croco.digital");
    die("ok");
} else {
    die("invalid hash");
}
