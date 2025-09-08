<?php

// No Direct Access
defined( '_BF2142_ADMIN' ) or die( 'Restricted access' );

// Start Session
start_session();

function start_session(){
   static $started = false;
   if(!$started){
       session_start();
       $started = true;
   }
}

function checkSession() {

	global $cfg;
	// Check Session Values
	if (!isset($_SESSION['adminAuth'])) {
		return false;
	} elseif (($_SESSION['adminAuth']) != sha1($cfg->get('admin_user').':'.$cfg->get('admin_pass'))) {
		return false;
	} elseif ($_SESSION['adminTime'] < time() - (30*60)) {	// Session Older tha n 30 minutes
		return false;
	} else {
		// Update Session Time
		$_SESSION['adminTime'] = time();
		return true;
	}
}


?>