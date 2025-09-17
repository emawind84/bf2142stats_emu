<?php
class Upgradedb
{
	public function Init() 
	{
		error_log(">>> processing Init!");
		// Make sure the database if offline
		if(DB_VER == '0.0.0')
			redirect('home');
			
		// Check for post data
		if($_POST['action'] == 'upgrade')
		{
			$this->Process();
		}
		else
		{
			// Db Version Compare
			// if(verCmp( DB_VER ) < verCmp( CODE_VER ))
			// {
			// 	$button = 'Run Updates';
			// 	$disabled = '';
			// }
			// else
			// {
			// 	$button = 'System Up To Date';
			// 	$disabled = 'disabled="disabled"';
			// }
		
			// // Setup the template
			// $Template = new Template();
			// $Template->set('button_text', $button);
			// $Template->set('disabled', $disabled);
			// $Template->render('upgradedb');
		}
	}
	
	public function Process()
	{
		global $cfg;
		$connection = @mysql_connect($cfg->get('db_host'), $cfg->get('db_user'), $cfg->get('db_pass'));
		@mysql_select_db($cfg->get('db_name'), $connection) or die("Database Error: " . mysql_error());

		$errors = array();
		
		// Get DB Version
		$curdbver = verCmp(DB_VER);
		
		// Import Upgrade Schema/Data
		require( ROOT . DS . 'include' . DS . 'db'. DS .'sql.dbupgrade.php' );
		
		// Process each upgrade only if the version is newer
		foreach ($sqlupgrade as $query) 
		{
			if ($curdbver < verCmp($query[1])) 
			{
				$result = mysql_query($query[2]);
				if (!$result) {
					$errors[] = mysql_errno() . ':' . mysql_error() . ' Query String: ' . $query[2];
				}
			} 
		}
		
		// Prepare for Output
		$html = '';
		if( !empty($errors) )
		{
			$html .= 'Upgrade failed to install all the neccessary database data...<br /><br />List of Errors:<br /><ul>';
			foreach($errors as $e)
			{
				$html .= '<li>'. $e .'</li>';
			}
			$html .= '</ul>';
			
			echo $html;
		}
		else
		{
			echo 'System Upgraded Successfully!';
		}
	}
}
