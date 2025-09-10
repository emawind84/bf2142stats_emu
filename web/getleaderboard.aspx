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

require(SYSTEM_PATH . DS . 'functions.php');
require(ROOT . DS . 'include' . DS . 'utils.php');


$r = $_REQUEST;
$str = "";
foreach ($r as $id => $val) {
    $str.=$id . "=" . $val . "&";
}
file_put_contents('getleaderboard.txt', $str);
//auth=[hslbhg9zRog6VggiqFFaA__&pos=1&after=17&type=combatscore&gsa=zdKY7TfbhEBG2]Abh8lyKY__&
//$_GET['auth'] = "FuG6aZRMnpej44D7i6Ck9w__";
//$_GET['pos'] = "1";
//$_GET['after'] = "17";
//$_GET['type'] = "weapon";
//$_GET['id'] = "0";
//$_GET['type'] = "combatscore";

$timestamp = time();
if (isset($_GET["auth"]) AND $_GET["auth"] != "") {
    $auth = $_GET["auth"];
} else {
    echo "None: No error.";
    exit;
}
if (isset($_GET["pos"]) AND $_GET["pos"] != "") {
    $getpos = $_GET["pos"] >= 1 ? $_GET["pos"] : 1;
} else {
    errorcode(9981);
    exit;
}
if (isset($_GET["web"]) AND $_GET["web"] != "" AND $_GET["web"] == 1) {
    $getweb = $_GET["web"];
} else {
    $getweb = false;
}

if (isset($_GET["after"]) AND $_GET["after"] != "" AND $_GET["after"] > 1) {
    if ($getweb != 1) {
        if ($_GET["after"] < 17) {
            $getafter = $_GET["after"];
        } else {
            $getafter = 18;
        }

    } else {
        if ($getweb == 1 AND $_GET["after"] < 50) {
            $getafter = $_GET["after"];
        } else {
            $getafter = 50;
        }
    }
} else {
    errorcode(9983);
}
if (isset($_GET["type"]) AND $_GET["type"] != "") {
    $gettype = $_GET["type"];
} else {
    errorcode(9984);
    exit;
}

if (isset($_GET["id"]) AND $_GET["id"] != "") {
    $id = $_GET["id"];
}


// Make sure we have a type, and its valid
$type = (isset($_GET['type'])) ? $_GET['type'] : false;
if (!$type) 
{
    $out = "E\nH\tasof\terr\n" .
        "D\t" . time() . "\tInvalid Syntax!\n";
	$num = strlen(preg_replace('/[\t\n]/', '', $out));
	echo "$\t$num\t$";
	exit;
}


require_once("ea_support.php");
require_once('include/_ccconfig.php');

$bfcoding = new ea_stats();
$code = $bfcoding->str2hex($bfcoding->DefDecryptBlock($bfcoding->getBase64Decode($auth)));
$authPID = hexdec($code[22] . $code[23] . $code[20] . $code[21] . $code[18] . $code[19] . $code[16] . $code[17]);
if (hexdec($code[26] . $code[27] . $code[24] . $code[25]) == 1) {
    $clType = 'server';
    $isServer = true;
} else {
    $clType = 'client';
    $isServer = false;
}


$connection = @mysql_connect($db_host, $db_user, $db_pass);

@mysql_select_db($db_name);
$query = "SELECT subaccount FROM `subaccount` WHERE id='" . $authPID . "' LIMIT 1";
$res = mysql_query($query);
checkSQLResult($res, $query);
if (!mysql_num_rows($res) AND $getweb != 1) {
    errorcode(1041);
    exit;
} else {
    $row1 = mysql_fetch_array($res);
}
$authPIDNick = rawurldecode($row1['subaccount']);






// Prepare our output header
$head = "O\n" .
"H\tsize\tasof\n";

$num = strlen(preg_replace('/[\t\n]/','',$head));
print $head;

$id  = (isset($_GET['id'])) ? $_GET['id'] : false;
$pid = (isset($_GET['pid'])) ? intval($_GET['pid']) : false;

// Optional parameters
$after  = (isset($_GET['after'])) ? intval($_GET['after']) : 0;
$before = (isset($_GET['before'])) ? intval($_GET['before']) : 0;
$pos    = (isset($_GET['pos'])) ? intval($_GET['pos']) : 1;
$pos = $pos < 1 ? 1 : $pos;
$offset = ($pos - 1) - $before;
$rowcount = $after;
$out    = "";

$WHERE = '1';
if (isset($_GET["dogTagFilter"]) AND $_GET["dogTagFilter"] == "1") {
	$WHERE .= " AND t.pid in (select victim_id from dogtag_events where killer_id = '" . $authPID . "')";
}
if (isset($_GET["ccFilter"]) AND $_GET["ccFilter"] != "") {
    $ccFilter = $_GET["ccFilter"];
	$WHERE .= " AND country = '" . $ccFilter . "'";
}
if ($pid) {
    $WHERE .= " AND t.pid = '{$pid}'";
}

if ($type == 'overallscore')
{
	$query = "SELECT COUNT(t.pid) as cnt FROM playerprogress t 
	left join subaccount s on s.id = t.pid 
	WHERE $WHERE AND gsco > -1";

	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$row = mysql_fetch_array($res);
	$count = $row['cnt'];
	$out .= "D\t{$count}\t" . time() . "\n";
	
	$core_query = "SELECT
		t.nick, t.pid, t.rnk, t.gsco,
		coalesce(s.country,'US') AS country,
		(SELECT coalesce(sum(cnt),0) FROM dogtag_events de WHERE de.victim_id = t.pid AND de.killer_id = '{$authPID}') AS dt,
		(SELECT COUNT(*)+1 FROM playerprogress a WHERE a.gsco > t.gsco) AS rank
	FROM
		playerprogress t
		left join subaccount s on s.id = t.pid
	";

	// ### START PLAYER DATA ###
	$query = $core_query . " WHERE t.pid = '{$authPID}'";
	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$out .= "H\trank\tpos\tpid\tnick\tglobalscore\tplayerrank\tcountrycode\tVet\t\n";
	while ($row = mysql_fetch_array($res))
	{
		$plpid = $row['pid'];
		$name = $row['nick'];
		$playerrank = $row['rnk'];
		$rank = $row['rank'];
		$country = strtoupper($row['country']);
		$globalscore = $row['gsco'];
		$out .= "D\t$rank\t1\t$plpid\t$name\t$globalscore\t$playerrank\t$country\t0\t\n";
	}
	// ### END PLAYER DATA ###

	// ### START LEADERBOARD DATA ###
	if ($count > 0)
	{
		$out .= "H\trank\tpos\tpid\tnick\tglobalscore\tplayerrank\tcountrycode\tVet\tdt\t\n";
		$query = $core_query . " WHERE $WHERE AND `gsco` > -1 ORDER BY gsco DESC";
		if (!$pid)
			$query .= " LIMIT {$offset}, {$rowcount}";

		// ErrorLog(">>> $query", 3);
		$res = mysql_query($query);
		checkSQLResult($res, $query);
		while ($row = mysql_fetch_array($res))
		{
			$plpid = $row['pid'];
			$name = $row['nick'];
			$playerrank = $row['rnk'];
			$rank = $row['rank'];
			$country = strtoupper($row['country']);
			$globalscore = $row['gsco'];
			$dogtags = $row['dt'];
			$out .= "D\t$rank\t" . $pos++ . "\t$plpid\t$name\t$globalscore\t$playerrank\t$country\t0\t$dogtags\t\n";
		}
	}
	// ### END LEADERBOARD DATA ###

}
elseif ($type == 'teamworkscore')
{
	$query = "SELECT COUNT(t.pid) as cnt FROM playerprogress t 
	left join subaccount s on s.id = t.pid 
	WHERE $WHERE AND twsc > -1";

	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$row = mysql_fetch_array($res);
	$count = $row['cnt'];
	$out .= "D\t{$count}\t" . time() . "\n";
	
	$core_query = "SELECT
		t.nick, t.pid, t.rnk, t.twsc,
		coalesce(s.country,'US') AS country,
		(SELECT coalesce(sum(cnt),0) FROM dogtag_events de WHERE de.victim_id = t.pid AND de.killer_id = '{$authPID}') AS dt,
		(SELECT COUNT(*)+1 FROM playerprogress a WHERE a.twsc > t.twsc) AS rank
	FROM
		playerprogress t
		left join subaccount s on s.id = t.pid
	";

	// ### START PLAYER DATA ###
	$query = $core_query . " WHERE t.pid = '{$authPID}'";
	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$out .= "H\trank\tpos\tpid\tnick\tteamworkscore\tplayerrank\tcountrycode\tVet\t\n";
	while ($row = mysql_fetch_array($res))
	{
		$plpid = $row['pid'];
		$name = $row['nick'];
		$playerrank = $row['rnk'];
		$rank = $row['rank'];
		$country = strtoupper($row['country']);
		$teamworkscore = $row['twsc'];
		$out .= "D\t$rank\t2\t$plpid\t$name\t$teamworkscore\t$playerrank\t$country\t0\t\n";
		//$out .= "D\t1\t2\t10003238\tPlayerX_E84\t35\t3\tIT\t0\t\n";
		//$out .= "D\t4\t1\t10131162\tFreteas\t2\t0\tUS\t0\t0\t\n";
	}
	// ### END PLAYER DATA ###

	// ### START LEADERBOARD DATA ###
	if ($count > 0)
	{
		$out .= "H\trank\tpos\tpid\tnick\tteamworkscore\tplayerrank\tcountrycode\tVet\tdt\t\n";
		$query = $core_query . " WHERE $WHERE AND `twsc` > -1 ORDER BY twsc DESC";
		if (!$pid)
			$query .= " LIMIT {$offset}, {$rowcount}";

		// ErrorLog(">>> $query", 3);
		$res = mysql_query($query);
		checkSQLResult($res, $query);
		while ($row = mysql_fetch_array($res))
		{
			$plpid = $row['pid'];
			$name = $row['nick'];
			$playerrank = $row['rnk'];
			$rank = $row['rank'];
			$country = strtoupper($row['country']);
			$teamworkscore = $row['twsc'];
			$dogtags = $row['dt'];
			$out .= "D\t$rank\t" . $pos++ . "\t$plpid\t$name\t$teamworkscore\t$playerrank\t$country\t0\t$dogtags\t\n";
		}
	}
	// ### END LEADERBOARD DATA ###
}
else if ($type == 'combatscore')
{
	$query = "SELECT COUNT(t.pid) as cnt FROM playerprogress t 
	left join subaccount s on s.id = t.pid 
	WHERE $WHERE AND klls > -1";

	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$row = mysql_fetch_array($res);
	$count = $row['cnt'];
	$out .= "D\t{$count}\t" . time() . "\n";
	
	$core_query = "SELECT
		t.nick, t.pid, t.rnk,
		t.klls, t.dths, t.ovaccu, t.kdr,
		coalesce(s.country,'US') AS country,
		(SELECT coalesce(sum(cnt),0) FROM dogtag_events de WHERE de.victim_id = t.pid AND de.killer_id = '{$authPID}') AS dt,
		(SELECT COUNT(*)+1 FROM playerprogress p WHERE p.klls > t.klls) AS rank
	FROM
		playerprogress t
		left join subaccount s on s.id = t.pid
	";

	// ### START PLAYER DATA ###
	$query = $core_query . " WHERE t.pid = '{$authPID}'";
	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$out .= "H\trank\tpos\tpid\tnick\tKills\tDeaths\tkdr\tAccuracy\tplayerrank\tcountrycode\tVet\t\n";
	while ($row = mysql_fetch_array($res))
	{
		$plpid = $row['pid'];
		$name = $row['nick'];
		$playerrank = $row['rnk'];
		$rank = $row['rank'];
		$country = strtoupper($row['country']);
		$teamworkscore = $row['twsc'];
		$kills = $row['klls'];
		$deaths = $row['dths'];
		$kdr = $row['kdr'];
		$ovaccu = $row['ovaccu'];
		$out .= "D\t$rank\t1\t$plpid\t$name\t$kills\t$deaths\t$kdr\t$ovaccu\t$playerrank\t$country\t0\t\n";
	}
	// ### END PLAYER DATA ###

	// ### START LEADERBOARD DATA ###
	if ($count > 0)
	{
		$out .= "H\trank\tpos\tpid\tnick\tKills\tDeaths\tkdr\tAccuracy\tplayerrank\tcountrycode\tVet\tdt\t\n";
		$query = $core_query . " WHERE $WHERE AND `klls` > -1 ORDER BY klls DESC";
		if (!$pid)
			$query .= " LIMIT {$offset}, {$rowcount}";

		// ErrorLog(">>> $query", 3);
		$res = mysql_query($query);
		checkSQLResult($res, $query);
		while ($row = mysql_fetch_array($res))
		{
			$plpid = $row['pid'];
			$name = $row['nick'];
			$playerrank = $row['rnk'];
			$rank = $row['rank'];
			$country = strtoupper($row['country']);
			$teamworkscore = $row['twsc'];
			$dogtags = $row['dt'];
			$kills = $row['klls'];
			$deaths = $row['dths'];
			$kdr = $row['kdr'];
			$ovaccu = $row['ovaccu'];
			$out .= "D\t$rank\t" . $pos++ . "\t$plpid\t$name\t$kills\t$deaths\t$kdr\t$ovaccu\t$playerrank\t$country\t0\t$dogtags\t\n";
		}
	}
	// ### END LEADERBOARD DATA ###


}
else if ($type == 'efficienty')
{
	// Efficiency = (Kills + Assists) / Deaths
	// klls deaths
}
else if ($type == 'commanderscore')
{

}
else if ($type == 'risingstar')
{

}
else if ($type == 'supremecommander')
{
	$out .= "D\t1\t" . time() . "\n";
	$out .= "H\trank\tnick\tWeek\tDate\tTimes\tVet\t\n" .
		"D\t1\t-*NORMAND*-\t38\t1321737736\t1\tFalse\t\n";

}
else if ($type == 'weapon')
{
	// res.rnk, res.pid, res.pos, res.nick, res.`wkls-".$id."` AS kills, res.`wdths-".$id."` AS deaths, res.`waccu-".$id."` AS accuracy, res.`wkdr-".$id."` AS kdr, res.country, res.Vet
	$query = "SELECT COUNT(t.pid) as cnt FROM playerprogress t 
	left join subaccount s on s.id = t.pid 
	left join stats_w w on w.pid = t.pid
	WHERE $WHERE AND `wkls-".$id."` > -1";

	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$row = mysql_fetch_array($res);
	$count = $row['cnt'];
	$out .= "D\t{$count}\t" . time() . "\n";
	
	$core_query = "SELECT
		t.nick, t.pid, t.rnk,
		`wkls-".$id."` AS kills, `wdths-".$id."` AS deaths, `waccu-".$id."` AS accuracy, 
		`wkdr-".$id."` AS kdr,
		coalesce(s.country,'US') AS country,
		(SELECT coalesce(sum(cnt),0) FROM dogtag_events de WHERE de.victim_id = t.pid AND de.killer_id = '{$authPID}') AS dt,
		(SELECT COUNT(*)+1 FROM `stats_w` ww WHERE ww.`wkls-".$id."` > w.`wkls-".$id."`) AS rank
	FROM
		playerprogress t
		left join subaccount s on s.id = t.pid
		left join stats_w w on w.pid = t.pid
	";

	// ### START PLAYER DATA ###
	$query = $core_query . " WHERE t.pid = '{$authPID}'";
	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$out .= "H\trank\tpos\tpid\tnick\tkills\tdeaths\tkdr\taccuracy\tplayerrank\tcountrycode\tVet\t\n";
	while ($row = mysql_fetch_array($res))
	{
		$plpid = $row['pid'];
		$name = $row['nick'];
		$playerrank = $row['rnk'];
		$rank = $row['rank'];
		$country = strtoupper($row['country']);
		$kills = $row['kills'];
		$deaths = $row['deaths'];
		$kdr = (round($row['kills']/$row['deaths'],2));
		$accu = $row['accuracy'];
		$out .= "D\t$rank\t1\t$plpid\t$name\t$kills\t$deaths\t$kdr\t$accu\t$playerrank\t$country\t0\t\n";
	}
	// ### END PLAYER DATA ###

	// ### START LEADERBOARD DATA ###
	if ($count > 0)
	{
		$out .= "H\trank\tpos\tpid\tnick\tkills\tdeaths\tkdr\taccuracy\tplayerrank\tcountrycode\tVet\tdt\t\n";
		$query = $core_query . " WHERE $WHERE AND `wkls-".$id."` > -1 ORDER BY `wkls-".$id."` DESC";
		if (!$pid)
			$query .= " LIMIT {$offset}, {$rowcount}";

		// ErrorLog(">>> $query", 3);
		$res = mysql_query($query);
		checkSQLResult($res, $query);
		while ($row = mysql_fetch_array($res))
		{
			$plpid = $row['pid'];
			$name = $row['nick'];
			$playerrank = $row['rnk'];
			$rank = $row['rank'];
			$country = strtoupper($row['country']);
			$kills = $row['kills'];
			$deaths = $row['deaths'];
			$kdr = (round($row['kills']/$row['deaths'],2));
			$accu = $row['accuracy'];
			$dogtags = $row['dt'];
			$out .= "D\t$rank\t" . $pos++ . "\t$plpid\t$name\t$kills\t$deaths\t$kdr\t$accu\t$playerrank\t$country\t0\t$dogtags\t\n";
		}
	}
	// ### END LEADERBOARD DATA ###

}
else if ($type == 'vehicle')
{
	$query = "SELECT COUNT(t.pid) as cnt FROM playerprogress t 
	left join subaccount s on s.id = t.pid 
	left join stats_v v on v.pid = t.pid
	WHERE $WHERE AND `vkls-".$id."` > -1";

	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$row = mysql_fetch_array($res);
	$count = $row['cnt'];
	$out .= "D\t{$count}\t" . time() . "\n";
	
	$core_query = "SELECT
		t.nick, t.pid, t.rnk,
		`vkls-".$id."` AS kills, `vdths-".$id."` AS deaths, `vrkls-".$id."` AS roadkills,
		coalesce(s.country,'US') AS country,
		(SELECT coalesce(sum(cnt),0) FROM dogtag_events de WHERE de.victim_id = t.pid AND de.killer_id = '{$authPID}') AS dt,
		(SELECT COUNT(*)+1 FROM `stats_v` vv WHERE vv.`vkls-".$id."` > v.`vkls-".$id."`) AS rank
	FROM
		playerprogress t
		left join subaccount s on s.id = t.pid
		left join stats_v v on v.pid = t.pid
	";

	// ### START PLAYER DATA ###
	$query = $core_query . " WHERE t.pid = '{$authPID}'";
	// ErrorLog(">>> $query", 3);
	$res = mysql_query($query);
	checkSQLResult($res, $query);
	$out .= "H\trank\tpos\tpid\tnick\tkills\tdeaths\troadkills\tplayerrank\tcountrycode\tVet\t\n";
	while ($row = mysql_fetch_array($res))
	{
		$plpid = $row['pid'];
		$name = $row['nick'];
		$playerrank = $row['rnk'];
		$rank = $row['rank'];
		$country = strtoupper($row['country']);
		$kills = $row['kills'];
		$deaths = $row['deaths'];
		$roadkills = $row['roadkills'];
		$out .= "D\t$rank\t1\t$plpid\t$name\t$kills\t$deaths\t$roadkills\t$playerrank\t$country\t0\t\n";
	}
	// ### END PLAYER DATA ###

	// ### START LEADERBOARD DATA ###
	if ($count > 0)
	{
		$out .= "H\trank\tpos\tpid\tnick\tkills\tdeaths\troadkills\tplayerrank\tcountrycode\tVet\tdt\t\n";
		$query = $core_query . " WHERE $WHERE AND `vkls-".$id."` > -1 ORDER BY `vkls-".$id."` DESC";
		if (!$pid)
			$query .= " LIMIT {$offset}, {$rowcount}";

		// ErrorLog(">>> $query", 3);
		$res = mysql_query($query);
		checkSQLResult($res, $query);
		while ($row = mysql_fetch_array($res))
		{
			$plpid = $row['pid'];
			$name = $row['nick'];
			$playerrank = $row['rnk'];
			$rank = $row['rank'];
			$country = strtoupper($row['country']);
			$dogtags = $row['dt'];
			$kills = $row['kills'];
			$deaths = $row['deaths'];
			$roadkills = $row['roadkills'];
			$out .= "D\t$rank\t" . $pos++ . "\t$plpid\t$name\t$kills\t$deaths\t$roadkills\t$playerrank\t$country\t0\t$dogtags\t\n";
		}
	}
	// ### END LEADERBOARD DATA ###

}
else 
{
	print 'Unknown type!';
}


// teamworkscore
// $out = "D\t1838\t1757349310\t
// H\tpid\tnick\tteamworkscore\tplayerrank\tcountrycode\trank\tVet\t
// D\t10003238\tPlayerX_E84\t1000\t40\tIT\t999\t1\t
// H\tpid\tnick\tteamworkscore\tplayerrank\tcountrycode\tVet\trank\t
// D\t11141\t[GD/US] AirJerr\t18733\t37\tUS\t0\t1\t
// D\t11176\tsoldier lourance\t16233\t37\tUS\t0\t2\t
// D\t11381\t Prister\t12471\t38\tUS\t0\t3\t
// D\t11298\t BrunoDerBaer\t11359\t33\tUS\t0\t4\t
// D\t11238\t[FR] cabjlc77\t10177\t27\tUS\t0\t5\t
// D\t11454\t Itoq\t9570\t30\tUS\t0\t6\t
// D\t10842\tAMAZING Carl.NL\t9377\t33\tUS\t0\t7\t
// D\t11195\t interceptor\t8747\t34\tUS\t0\t8\t
// D\t10970\t Mumie\t8476\t35\tUS\t0\t9\t
// D\t11237\t OJ_gal\t8031\t29\tUS\t0\t10\t
// D\t12529\t Ronin\t7977\t30\tUS\t0\t11\t
// D\t10956\t SaloSniper\t7786\t33\tUS\t0\t12\t
// D\t11396\t jacky41\t7503\t26\tUS\t0\t13\t
// D\t16247\t AlphaOne1989\t7360\t27\tUS\t0\t14\t
// D\t15324\t-=AT=- Tirola\t7226\t28\tUS\t0\t15\t
// D\t11355\tL.A_ZeoN Despise1_OcK\t6775\t27\tUS\t0\t16\t
// D\t13141\t Queeny\t6439\t27\tUS\t0\t17\t\n";

// overallscore
// $out = "D\t1838\t1757349310\t
// H\tpid\tnick\tglobalscore\tplayerrank\tcountrycode\trank\tVet\t
// D\t10003238\tPlayerX_E84\t1000\t40\tIT\t999\t1\t
// H\tpid\tnick\tglobalscore\tplayerrank\tcountrycode\tVet\trank\t
// D\t11141\t[GD/US] AirJerr\t18733\t37\tUS\t0\t1\t
// D\t11176\tsoldier lourance\t16233\t37\tUS\t0\t2\t
// D\t11381\t Prister\t12471\t38\tUS\t0\t3\t
// D\t11298\t BrunoDerBaer\t11359\t33\tUS\t0\t4\t
// D\t11238\t[FR] cabjlc77\t10177\t27\tUS\t0\t5\t
// D\t11454\t Itoq\t9570\t30\tUS\t0\t6\t
// D\t10842\tAMAZING Carl.NL\t9377\t33\tUS\t0\t7\t
// D\t11195\t interceptor\t8747\t34\tUS\t0\t8\t
// D\t10970\t Mumie\t8476\t35\tUS\t0\t9\t
// D\t11237\t OJ_gal\t8031\t29\tUS\t0\t10\t
// D\t12529\t Ronin\t7977\t30\tUS\t0\t11\t
// D\t10956\t SaloSniper\t7786\t33\tUS\t0\t12\t
// D\t11396\t jacky41\t7503\t26\tUS\t0\t13\t
// D\t16247\t AlphaOne1989\t7360\t27\tUS\t0\t14\t
// D\t15324\t-=AT=- Tirola\t7226\t28\tUS\t0\t15\t
// D\t11355\tL.A_ZeoN Despise1_OcK\t6775\t27\tUS\t0\t16\t
// D\t13141\t Queeny\t6439\t27\tUS\t0\t17\t\n";


// ############################################################

@mysql_close($connection);

$num += strlen(preg_replace('/[\t\n]/','',$out));
print $out . "$\t" . $num . "\t$";


function errorcode($errorcode=104) {
    $Out = "E\t" . $errorcode;
    $countOut = preg_replace('/[\t\n]/', '', $Out);
    print $Out . "\n$\t" . strlen($countOut) . "\t$\n";
}

?>