<?php
ob_start();



/*
| ---------------------------------------------------------------
| Define Constants
| ---------------------------------------------------------------
*/
define('DS', DIRECTORY_SEPARATOR);
define('ROOT', dirname(__FILE__) . DS . '..');
define('SYSTEM_PATH', ROOT);


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

// Make Sure Script doesn't timeout even if the user disconnects!
set_time_limit(300);
ignore_user_abort(true);




$LOG = 1;
function errorcode($errorcode=104) {
    $Out = "E\t" . $errorcode;
    $countOut = preg_replace('/[\t\n]/', '', $Out);
    print $Out . "\n$\t" . strlen($countOut) . "\t$\n";
}

function chz($val) {
    if ($val == 0)
        return 1;
    else
        return $val;
}

$allow_db_changes = true;
$allow_db_show = true;

//Make Sure Script doesn't timeout even if the user disconnects!
set_time_limit(0);
ignore_user_abort(true);

// Import configuration
require_once SYSTEM_PATH . '/include/_ccconfig.php';
require_once SYSTEM_PATH . '/include/utils.php';

$cfg = new Config();
DEFINE("_ERR_RESPONSE", "E\nH\tresponse\nD\t<font color=\"red\">ERROR</font>: ");

// Open database connection
$connection = @mysql_connect($db_host, $db_user, $db_pass);
@mysql_select_db($db_name, $connection);


$query0 = "SELECT ip FROM `servers` WHERE authorised=1";
$result0 = mysql_query($query0);
checkSQLResult($result0, $query0);
$game_hosts = array();

if (mysql_num_rows($result0)) {
    while ($data0 = mysql_fetch_assoc($result0)) {
        $game_hosts[] = $data0['ip'];
    }
//print_r($game_hosts);
} else {
    $errmsg = "NOT FOUND Authorised gamehosts in DB";
    ErrorLog($errmsg, 0);
    die(_ERR_RESPONSE . $errmsg);
}

// Check Database Version
//$curdbver = getDbVer();
//
//if ($curdbver != $cfg->get('db_expected_ver')) {
//	$errmsg = "Database version expected: ".$cfg->get('db_expected_ver').", Found: {$curdbver}";
//	ErrorLog($errmsg, 1);
//	die();
//} else {
//	$errmsg = "Database version expected: ".$cfg->get('db_expected_ver').", Found: {$curdbver}";
//	ErrorLog($errmsg, 3);
//}
@mysql_close($connection);

define('_BF2142_ADMIN', '1');
require_once('../include/admin.security.php');
require_once('../include/admin.content.php');
require_once('../include/admin.process.php');
