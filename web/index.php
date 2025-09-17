<?php
ob_start();



/*
| ---------------------------------------------------------------
| Define Constants
| ---------------------------------------------------------------
*/
define('_BF2142_ADMIN', '1');
define('CODE_VER', '1.11.0');
define('CODE_VER_DATE', '2025-09-12');
define('DS', DIRECTORY_SEPARATOR);
define('ROOT', dirname(__FILE__) . DS);
define('SYSTEM_PATH', ROOT . DS . 'system');
define('SNAPSHOT_TEMP_PATH', SYSTEM_PATH . DS . 'snapshots' . DS . 'temp');
DEFINE("_ERR_RESPONSE", "E\nH\tresponse\nD\t<font color=\"red\">ERROR</font>: ");

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

require(ROOT . DS . 'include' . DS . '_ccconfig.php');
require(ROOT . DS . 'include' . DS . 'utils.php');
require(SYSTEM_PATH . DS . 'core'. DS .'AutoLoader.php');
require(SYSTEM_PATH . DS . 'functions.php');

$cfg = new Config();

// Define our database version!
define('DB_VER', getDbVer());

// Check Database Version... this is rather important!
if(DB_VER != CODE_VER)
{
    $errmsg = "Database version expected: ". CODE_VER .", Found: ". DB_VER;
    ErrorLog($errmsg, 1);
    //die("<font color='red'>ERROR:</font> {$errmsg}");
} 
else 
{
    $errmsg = "Database version expected: ". CODE_VER .", Found: ". DB_VER;
    ErrorLog($errmsg, 3);
}

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