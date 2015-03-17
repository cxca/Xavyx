<?
//function apns($IdPhoto, $comment)
set_time_limit(0);                   // ignore php timeout

{
// authentication
//include "lib.php";
//Substring COMMENT
$counter = 0;
//global $link;
//$IdPhoto = '481397176008';
// get the id, token from database			

//$result = myquery("SELECT deviceToken, appIdentifier, badge  FROM devices 
//					WHERE appName = 'destroythem' && strcmp(appVersion, '1.0.4.0') < 0");
					

	
//if($row = mysqli_fetch_array($result))
{
//ignore_user_abort(true);             // keep on going even if user pulls the plug*
//while(ob_get_level())ob_end_clean();
//ob_implicit_flush(true);             // output stuff directly

$apple_identifier = 'com.xavyx.xavyxapp';//$row["appIdentifier"];
//$deviceToken = $row["deviceToken"];
$deviceToken = 'e5021f0c26e8aff743a1b273efa32654350082977525d0864cba3ec20b6bd934';

//$badgeCount = $row["badge"];

//myquery("UPDATE devices SET pushSent = pushSent - 1 WHERE deviceToken = '$deviceToken'");


//Setup notification message
$body = array();

$body['aps'] = array('alert' => 'There is an update available!');


$body['aps']['notifurl'] = 'http://www.xavyx.com';
$body['aps']['badge'] = 0;
$body['aps']['sound'] = 'default';
$body['aps']['action'] = 'xavyxComment';

//Setup stream (connect to Apple Push Server)
$passphrase = '';
$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'passphrase', '');
stream_context_set_option($ctx, 'ssl', 'local_cert', 'apns_development.pem');
$fp = stream_socket_client('ssl://gateway.sandbox.push.apple.com:2195', $err, $errstr, 60, STREAM_CLIENT_CONNECT, $ctx);
    stream_set_blocking ($fp, 0); 
// This allows fread() to return right away when there are no errors. But it can also miss errors during 
//  last  seconds of sending, as there is a delay before error is returned. Workaround is to pause briefly 
// AFTER sending last notification, and then do one more fread() to see if anything else is there.

if (!$fp) {
//ERROR
 echo "Failed to connect (stream_socket_client): $err $errstrn";

} else {

// Keep push alive (waiting for delivery) for 90 days
$apple_expiry = time() + (90 * 24 * 60 * 60); 

// Loop thru tokens from database


$payload = json_encode($body);
            
// Enhanced Notification
$msg = pack("C", 1) . pack("N", $apple_identifier) . pack("N", $apple_expiry) . pack("n", 32) . pack('H*', str_replace(' ', '', $deviceToken)) . pack("n", strlen($payload)) . $payload; 
            
// SEND PUSH
fwrite($fp, $msg);

// We can check if an error has been returned while we are sending, but we also need to 
// check once more after we are done sending in case there was a delay with error response.
checkAppleErrorResponse($fp); 


// Workaround to check if there were any errors during the last seconds of sending.
// Pause for half a second. 
// Note I tested this with up to a 5 minute pause, and the error message was still available to be retrieved
//usleep(500000); 

checkAppleErrorResponse($fp);


		//print json_encode('Completed');
$counter = $counter +1;
//mysqli_close($link);
fclose($fp);

}
}
}

echo 'Completed';
//echo 'Total: '.sizeof($result);
echo 'Sent:'.$counter;
// FUNCTION to check if there is an error response from Apple
// Returns TRUE if there was and FALSE if there was not
function checkAppleErrorResponse($fp) {

//byte1=always 8, byte2=StatusCode, bytes3,4,5,6=identifier(rowID). 
// Should return nothing if OK.

//NOTE: Make sure you set stream_set_blocking($fp, 0) or else fread will pause your script and wait 
// forever when there is no response to be sent. 

$apple_error_response = fread($fp, 6);

if ($apple_error_response) {

// unpack the error response (first byte 'command" should always be 8)
$error_response = unpack('Ccommand/Cstatus_code/Nidentifier', $apple_error_response); 

if ($error_response['status_code'] == '0') {
$error_response['status_code'] = '0-No errors encountered';

} else if ($error_response['status_code'] == '1') {
$error_response['status_code'] = '1-Processing error';

} else if ($error_response['status_code'] == '2') {
$error_response['status_code'] = '2-Missing device token';

} else if ($error_response['status_code'] == '3') {
$error_response['status_code'] = '3-Missing topic';

} else if ($error_response['status_code'] == '4') {
$error_response['status_code'] = '4-Missing payload';

} else if ($error_response['status_code'] == '5') {
$error_response['status_code'] = '5-Invalid token size';

} else if ($error_response['status_code'] == '6') {
$error_response['status_code'] = '6-Invalid topic size';

} else if ($error_response['status_code'] == '7') {
$error_response['status_code'] = '7-Invalid payload size';

} else if ($error_response['status_code'] == '8') {
$error_response['status_code'] = '8-Invalid token';

} else if ($error_response['status_code'] == '255') {
$error_response['status_code'] = '255-None (unknown)';

} else {
$error_response['status_code'] = $error_response['status_code'].'-Not listed';

}
		print json_encode('ERROR');

//echo '<br><b>+ + + + + + ERROR</b> Response Command:<b>' . $error_response['command'] . '</b>&nbsp;&nbsp;&nbsp;Identifier:<b>' . $error_response['identifier'] . '</b>&nbsp;&nbsp;&nbsp;Status:<b>' . $error_response['status_code'] . '</b><br>';

//echo 'Identifier is the rowID (index) in the database that caused the problem, and Apple will disconnect you from server. To continue sending Push Notifications, just start at the next rowID after this Identifier.<br>';

return true;
}
       
return false;
}

