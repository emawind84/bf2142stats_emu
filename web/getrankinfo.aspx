<?php

/*
| ---------------------------------------------------------------
| Define Constants
| ---------------------------------------------------------------
*/
define('DS', DIRECTORY_SEPARATOR);
define('ROOT', dirname(__FILE__));
define('SYSTEM_PATH', ROOT . DS . 'system');


/*
| ---------------------------------------------------------------
| Set Error Reporting and Zlib Compression
| ---------------------------------------------------------------
*/
error_reporting(E_ALL);
ini_set("log_errors", "1");
if (!getenv('PHP_VERSION')) {
    # Not running in docker. Log errors to file
    ini_set("error_log", SYSTEM_PATH . DS . 'logs' . DS . 'php_errors.log');
}
ini_set("display_errors", "0");

// Disable Zlib Compression
ini_set('zlib.output_compression', '0');

$timestamp = time();
$r = $_REQUEST;
$str = "";
foreach ($r as $id => $val) {
    $str.=$id . "=" . $val . "&";
}
file_put_contents('GetRankInfo.txt', $str);