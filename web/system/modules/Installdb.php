<?php
class Installdb
{
	public function Init() 
	{
		// Check for post data
		if($_POST['action'] == 'install')
		{
			$this->Install();
		}
		else
		{
			// Setup the template
			// $Template = new Template();
			// $Template->set('config', Config::FetchAll());
			// $Template->render('installdb');
		}
	}
	
	public function Install()
	{
		// Load the config / Database
		$errors = array();
		
		global $cfg;
		$connection = @mysql_connect($cfg->get('db_host'), $cfg->get('db_user'), $cfg->get('db_pass'));
		@mysql_select_db($cfg->get('db_name'), $connection) or die("Database Error: " . mysql_error());
		
		// Import Schema and Default data
		require( ROOT . DS . 'include' . DS . 'db'. DS . 'sql.dbschema.php' );
		require( ROOT . DS . 'include' . DS . 'db'. DS . 'sql.dbdata.php' );
		
		// Process Schema
		foreach ($sqlschema as $query) 
		{
			$result = mysql_query($query[1]);
			if (!$result) {
				$errors[] = mysql_errno() . ':' . mysql_error() . ' Query String: ' . $query[1];
			}
		}
		
		// Process Defaut Data
		foreach ($sqldata as $query) 
		{
			$result = mysql_query($query[1]);
			if (!$result) {
				$errors[] = mysql_errno() . ':' . mysql_error() . ' Query String: ' . $query[1];
			}
		}
		
		// Prepare for Output
		$html = '';
		if( !empty($errors) )
		{
			$html .= 'Installation failed to install all the neccessary database data...<br /><br />List of Errors:<br /><ul>';
			foreach($errors as $e)
			{
				$html .= '<li>'. $e .'</li>';
			}
			$html .= '</ul>';
			
			echo $html;
		}
		else
		{
			echo 'System Installed Successfully! <a href="?task=testconfig">Click here to go to the System Test screen</a> to make sure everything is in working order.';
		}
	}
}
