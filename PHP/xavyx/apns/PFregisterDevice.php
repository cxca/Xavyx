<?php

	include "../lib.php";
	
	if (!isset($_REQUEST['deviceToken']) || $_REQUEST['deviceToken'] == '') {

    echo $_REQUEST['deviceToken'];
    exit("No deviceToken set");
	}
	
	if (!isset($_REQUEST['IdUser']) || $_REQUEST['IdUser'] == '') {
		echo $_REQUEST['appId'];
		exit('Not IdUser set');
	}
	$token = $_REQUEST['deviceToken'];
	$IdUser = $_REQUEST['IdUser'];
		global $link;
	$token = mysqli_real_escape_string($link, $token);
	$IdUser = mysqli_real_escape_string($link, $IdUser);
	
	//echo 'Token '.$token."<br>"; 
	//echo 'Id '.$IdUser;
	$result = myquery("SELECT id FROM deviceTokens WHERE IdUser = '$IdUser' AND token = '$token'"); 
	$nr = mysqli_num_rows($result);
	echo 'nr '.$nr;
	if($nr == 0)
	{
		$result = myquery("INSERT INTO deviceTokens (IdUser,token) VALUES ('$IdUser', '$token')"); 
	//echo $result['error'];
	if (!$result['error']) 
		print json_encode($result);
	else
		errorJson('Could not save comment');
	}

?>