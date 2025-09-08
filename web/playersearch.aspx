<?php
//exit;


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

$r = $_REQUEST;
$str = "";
foreach ($r as $id => $val) {
    $str.=$id . "=" . $val . "&";
}
file_put_contents('playersearch.txt', $str);
//auth=YCoaqfZZaT8sEDUIaUeFhw__&nick=Necro&gsa=qWGyKsTLrpsTfbNoZ6UJ]4__&
//$_GET["auth"] = "YCoaqfZZaT8sEDUIaUeFhw__";
//$_GET["nick"] = "Necro";
$timestamp = time();
if(isset($_GET["auth"]) AND $_GET["auth"] != "") {	$getAUTH = $_GET["auth"];	} else {	echo "None: No error.";exit;	}

require_once("ea_support.php");
require_once('include/_ccconfig.php');

$bfcoding  = new ea_stats();
$code = $bfcoding->str2hex($bfcoding->DefDecryptBlock($bfcoding->getBase64Decode($getAUTH)));
if ((hexdec($code[6].$code[7].$code[4].$code[5].$code[2].$code[3].$code[0].$code[1])+708) < $timestamp) {	echo "ExpiredAuth: Expired authentication token";exit;	}
/*
0  4C524F45 7
8  64000000 15
16 9703F104 23
24 0000     27
28 87C3     31
*/

$authPID = 0;
//if(isset($_GET["pid"]) AND $_GET["pid"] != "") {	$authPID = $_GET["pid"];	}
if(isset($_GET["nick"]) AND $_GET["nick"] != "") {	$nick = $_GET["nick"];	} else {	$nick = '%2a';	}
//if(isset($_GET["pos"]) AND $_GET["pos"] != "" AND $_GET["pos"] > 1) {	$getPOS = $_GET["pos"];	} else {	$pos = 1;	}
//if(isset($_GET["after"]) AND $_GET["after"] != "" AND $_GET["after"] > 17) {	$getafter = $_GET["after"];	} else {	$after = 17;	}

$connection = @mysql_connect($db_host, $db_user, $db_pass);
@mysql_select_db($db_name);
$nick = preg_replace("/\*+/", chr(46).chr(42), urldecode($nick));

$Out = "O
H\tpid\tasof
D\t".$authPID."\t".$timestamp."
H\tsearchpattern
D\t".$nick."
H\tpid\tnick";

$query1 = "SELECT id, subaccount FROM `subaccount` WHERE subaccount REGEXP '".$nick."' LIMIT 20";
$result1 = mysql_query($query1) or die(mysql_error());
if (!mysql_num_rows($result1)) {
	errorcode(104);
	exit;
} else {
	while ($row = mysql_fetch_array($result1)) {
		$pid = $row['id'];
		$nickname = rawurldecode($row['subaccount']);
		$Out .= "\nD\t".$pid."\t".$nickname;
		error_log(">>>".$row['subaccount']);
	}
}
/*
O
H	pid	asof
D	81260470	1162863088
H	searchpattern
D	*
H	pid	nick
D	82420394	a$$$
D	81339995	A$$|Mudsy
D	81465685	A$$A$$1N
D	81466385	A$$A$$1N.
D	81373584	a$$a$$in
D	83288743	A$$A$$IN1793
D	81885985	A$$A$$IN187
D	81607449	A$$A$$IN444
D	82852033	A$$a$$inBlade
D	81259095	A$$Annihilator
D	82972235	A$$AS$IN
D	82293340	A$$asiN8toR
D	82598628	A$$asinSniper
D	82495250	A$$aultmaster
D	82166195	a$$blaster
D	81315175	A$$Grinder
D	81940739	A$$h@lli@
D	81797133	A$$holio
D	83352351	A$$I<er@$in
D	81838773	A$$INATOR
$	426	$
*/
$countOut = preg_replace('/[\t\n]/','',$Out);
print $Out."\n$\t".strlen($countOut)."\t$";
@mysql_close($connection);
function errorcode($errorcode=104) {
	$Out = "E\t".$errorcode;
	$countOut = preg_replace('/[\t\n]/','',$Out);
	print $Out."\n$\t".strlen($countOut)."\t$";
}
?>