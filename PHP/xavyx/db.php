<?php
//Set credentials

define('DB_SERVER', 'localhost');
define('DB_USERNAME', 'user');
define('DB_PASSWORD', 'pass');
define('DB_DATABASE', 'database');
if(!$connection = @mysqli_connect(DB_SERVER,DB_USERNAME,DB_PASSWORD,DB_DATABASE))
{
	    echo 'Could not connect to mysql';

	exit;
}

$path = "xavyx"; //Server Directory 
$domain = "www.yourdomain.com";//Set domain
$base_url='http://'.$domain.'/xavyx/email_activation/';

?>
