<?php
include "lib.php";

		$id = $_REQUEST['id'];
	
		$result = myquery("UPDATE notifications SET status = 'read' WHERE id = '$id'");
			print json_encode($result);

?>


