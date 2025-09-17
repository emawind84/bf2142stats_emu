<?php

define('CONFIG_FILE', ROOT . DS . 'include' . DS . '_ccconfig.php');

//We check each ip in the array and return response
function checkIpAuth($chkhosts) {
    if (isset($_SERVER['REMOTE_ADDR']) && $_SERVER['REMOTE_ADDR'] != "") {
        $ip_s = $_SERVER['REMOTE_ADDR'];
    }



    if ($ip_s != "" && isIPInNetArray($ip_s, $chkhosts)) {
        return 1; // Authorised HOST IP
    } else {
        return 0; // UnAuthorised HOST IP
    }
}

// Quote variable to make safe (SQL Injection protection code)
function quote_smart($value) {
    // Stripslashes
    if (get_magic_quotes_gpc()) {
        $value = stripslashes($value);
    }
    // Quote if not integer
    if (!is_numeric($value)) {
        $value = mysql_real_escape_string($value);
    }
    return $value;
}

// Get Database Version
function getDbVer() {
    $cfg = new Config();
    $curver = '0.0.0';

    $connection = @mysql_connect($cfg->get('db_host'), $cfg->get('db_user'), $cfg->get('db_pass'));
    if (!$connection) {
        echo 1;
        // DB Server error
    } else {
        $query = "SELECT dbver FROM _version";
        if (!mysql_select_db($cfg->get('db_name'), $connection)) {
            // DB Error
        } else {
            $result = mysql_query($query);
//			if ($result && mysql_num_rows($result)) {
            $row = mysql_fetch_array($result);
            if (isset($row['dbver']))
                $curver = $row['dbver'];
//			} else {
//				$query = "SHOW TABLES LIKE 'player'";
//				$result = mysql_query($query);
//				if (mysql_num_rows($result)) {
//					$curver = '1.2+';
//				}
//			}
        }
    }
    // Close database connection
    @mysql_close($connection);
    return $curver;
}

// Check SQL Results
function checkSQLResult($result, $query) {
    if (!$result) {
        $msg = mysql_errno() . ':' . mysql_error() . ' Query String: ' . $query;
        ErrorLog($msg, 1);
        return 1;
    } else {
        return 0;
    }
}

function get_ext_ip() {

    $url = 'http://this-ip.com/';
    $get = implode("\n", getPageContents($url));
    preg_match('/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/', $get, $ip);
    $var_ipaddr = $ip[0];
    return $var_ipaddr;
}

function chkPath($path) {
    if (($path{strlen($path) - 1} != "/") && ($path{strlen($path) - 1} != "\\")) {
        return $path . "/";
    } else {
        return $path;
    }
}

// Config Handling class
class Config {

    var $data = array();
    var $configFile = CONFIG_FILE; //Default Config File

    function Config() {
        $this->Load();
    }

    function Save() {
        $cfg = "<?php\n";
        $cfg .= "/***************************************\n";
        $cfg .= "*  Battlefield 2 Private Stats Config  *\n";
        $cfg .= "****************************************\n";
        $cfg .= "* All comments have been removed from  *\n";
        $cfg .= "* this file. Please use the Web Admin  *\n";
        $cfg .= "* to change values.                    *\n";
        $cfg .= "***************************************/\n";
        foreach ($this->data as $key => $val) {
            if (is_numeric($val)) {
                $cfg .= "\$$key = " . $val . ";\n";
            } elseif ($key == 'admin_hosts' || $key == 'game_hosts' || $key == 'stats_local_pids') {
                if (!is_array($val)) {
                    $val_r = explode("\n", $val);
                } else {
                    $val_r = $val;
                }
                $val_s = "";
                foreach ($val_r as $item) {
                    $val_s .= "'" . trim($item) . "',";
                }
                $cfg .= "\$$key = array(" . substr($val_s, 0, -1) . ");\n";
            } else {
                $cfg .= "\$$key = '" . addslashes($val) . "';\n";
            }
        }
        $cfg .= "?>";

        @copy($this->configFile, $this->configFile . '.bak');
        if (phpversion() < 5) {
            $file = @fopen($this->configFile, 'w');
            if ($file === false) {
                return false;
            } else {
                @fwrite($file, $cfg);
                @fclose($file);
                return true;
            }
        } else {
            if (@file_put_contents($this->configFile, $cfg)) {
                return true;
            } else {
                return false;
            }
        }
    }

    function Load() {
        if (file_exists($this->configFile)) {
            include ( $this->configFile );
            $vars = get_defined_vars();
            foreach ($vars as $key => $val) {
                if ($key != 'this' && $key != 'data') {
                    $this->data[$key] = $val;
                }
            }
            return true;
        } else {
            return false;
        }
    }

    function set($key, $val) {
        $this->data[$key] = $val;
    }

    function get($key) {
        if (isset($this->data[$key])) {
            return $this->data[$key];
        }
    }

}

/**
 *
 * @param type $arr
 * @param type $dir true, false
 */
function mySort($arr, $dir) {
    arsort($arr, $dir);
    reset($arr);
    $firstKey = key($arr);
    $m = null;
    preg_match("/.+-(.+)/", $firstKey, $m);
    if (isset($m[1])) {
        return $m[1];
    } else {
        return 0;
    }
}

function quote_keys($json_like) {
    return preg_replace('/(\{|,)\s*(\d+)\s*:/', '$1 "$2":', $json_like);
}

?>