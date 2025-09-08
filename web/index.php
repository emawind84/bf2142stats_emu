<?php
ob_start();



/*
| ---------------------------------------------------------------
| Define Constants
| ---------------------------------------------------------------
*/
define('DS', DIRECTORY_SEPARATOR);
define('ROOT', dirname(__FILE__) . DS);
define('SYSTEM_PATH', ROOT . DS . 'system');
define('SNAPSHOT_TEMP_PATH', SYSTEM_PATH . DS . 'snapshots' . DS . 'temp');

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

define('_BF2142_ADMIN', '1');
require(ROOT . DS . 'include' . DS . '_ccconfig.php');
require(ROOT . DS . 'include' . DS . 'utils.php');
require(SYSTEM_PATH . DS . 'core'. DS .'AutoLoader.php');
require(SYSTEM_PATH . DS . 'functions.php');

$cfg = new Config();
DEFINE("_ERR_RESPONSE", "E\nH\tresponse\nD\t<font color=\"red\">ERROR</font>: ");

// Open database connection
$connection = @mysql_connect($db_host, $db_user, $db_pass);
@mysql_select_db($db_name, $connection);


// Check Database Version
$dbver = getDbVer();
error_log(">>> DB VERSION: {$dbver}");
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

// Register AutoLoader
AutoLoader::Register();
AutoLoader::RegisterPath( path( SYSTEM_PATH, 'core' ) );

// First, Lets make sure the IP can view the ASP
if(!isIPInNetArray( Auth::ClientIp(), $cfg->get('admin_hosts') ))
die("<font color='red'>ERROR:</font> You are NOT Authorised to access this Page! (Ip: ". Auth::ClientIp() .")");

// Always set a post and get actions
if(!isset($_POST['action'])) $_POST['action'] = null;
if(!isset($_GET['action']))  $_GET['action'] = null;

// Get / Set our current task
$task = (isset($_GET['task'])) ? $_GET['task'] : false;
if($task == false)
{
    (isset($_POST['task'])) ? $_GET['task'] = $_POST['task'] : $_GET['task'] = 'home';
}

require(ROOT . DS . 'include' . DS . 'admin.security.php');
require(ROOT . DS . 'include' . DS . 'admin.process.php');
require(ROOT . DS . 'include' . DS . 'admin.content.php');
require(ROOT . DS . 'include' . DS . 'admin.menu.php');


?>