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
file_put_contents('ValidatePlayer.txt', $str);

//auth=MVI[zJuk3ZC8l2]4rVIvj5__&tid=0&SoldierNick=Sinthetix&pid=5&
//$_GET['auth'] = "MVI[zJuk3ZC8l2]4rVIvj5__";
//$_GET['SoldierNick'] = "Sinthetix";
//$_GET['pid'] = "5";

if (isset($_GET["auth"]) AND $_GET["auth"] != "") {
    $auth = $_GET["auth"];
} else {
    echo "None: No error.";
    exit;
}
$nick = $_GET['SoldierNick'];
$pid = $_GET['pid'];

require_once("ea_support.php");
require_once('include/_ccconfig.php');
require_once ('include/rankSettings.php');


//O 
//H pid nick spid asof 
//D 82490978 Bigbacon 82490978 1310658026 
//H result 
//D Ok $ 62 $ 
//echo "DecryptionFailure: Authentication token decryption failure";
//die;
$Out = "O\n" .
 "H\tpid\tnick\tspid\tasof\n" .
 "D\t".$pid."\t".$nick."\t".$pid."\t". $timestamp."\n".
 "H\tresult\n".
 "D\tOk";

$countOut = preg_replace('/[\t\n]/', '', $Out);
print $Out . "\n$\t" . strlen($countOut) . "\t$\n";
//file_put_contents('ValidatePlayer2.txt', $Out . "\n$\t" . strlen($countOut) . "\t$\n");