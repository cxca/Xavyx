<?
/**
 * Logging class:
 * - contains lfile, lwrite and lclose public methods
 * - lfile sets path and name of log file
 * - lwrite writes message to the log file (and implicitly opens log file)
 * - lclose closes log file
 * - first call of lwrite method will open log file implicitly
 * - message is written with the following format: [d/M/Y:H:i:s] (script name) message
 */
class Logging {
    // declare log file and file pointer as private properties
    private $log_file, $fp;
    // set log file (path and name)
    public function lfile($path) {
        $this->log_file = $path;
    }
    // write message to the log file
    public function lwrite($message) {
        // if file pointer doesn't exist, then open log file
        if (!is_resource($this->fp)) {
            $this->lopen();
        }
        // define script name
        $script_name = pathinfo($_SERVER['PHP_SELF'], PATHINFO_FILENAME);
        // define current time and suppress E_WARNING if using the system TZ settings
        // (don't forget to set the INI setting date.timezone)
        $time = @date('[d/M/Y:H:i:s]');
        // write current time, script name and message to the log file
        fwrite($this->fp, "$time ($script_name) $message" . PHP_EOL);
    }
    // close log file (it's always a good idea to close a file when you're done with it)
    public function lclose() {
        fclose($this->fp);
    }
    // open log file (private method)
    private function lopen() {
        // in case of Windows set default log file
        if (strtoupper(substr(PHP_OS, 0, 3)) === 'WIN') {
            $log_file_default = 'c:/php/logfile.txt';
        }
        // set default log file for Linux and other systems
        else {
            $log_file_default = '/tmp/logfile.txt';
        }
        // define log file from lfile method or use previously set default
        $lfile = $this->log_file ? $this->log_file : $log_file_default;
        // open log file for writing only and place file pointer at the end of the file
        // (if the file does not exist, try to create it)
        $this->fp = fopen($lfile, 'a') or exit("Can't open $lfile!");
    }
}
{
// authentication
//Substring COMMENT
set_time_limit(0); 
$pushMessage;
if(strlen($comment) >= 24)
	$pushMessage = substr($comment, 0, 23).'...';
else
	$pushMessage = $comment;
//Concatenate User name
$userResult =  myquery("SELECT firstName, lastName, profileImage FROM login WHERE IdUser = '$IdUser' limit 1");
if($row = mysqli_fetch_array($userResult)) {
	$fullName = $row["firstName"].' '.$row["lastName"];
	$pushMessage = $fullName.': '.$pushMessage;
}

global $link;
//$IdPhoto = '481397176008';

// get the id, token from database			
$result1 =  myquery("SELECT * FROM photoCommentsAPNS 
					WHERE IdPhoto = '$IdPhoto'");
					
					//Insert notification
$type = 'photoComment';	
	
while($row1 = mysqli_fetch_assoc($result1)) {
$deviceIdUser = $row1["IdUser"]; 


$result =  myquery("SELECT * FROM deviceTokens WHERE IdUser = '$deviceIdUser'");


//Setup notification message
$body = array();
$body['aps'] = array('alert' => $pushMessage);
$body['aps']['notifurl'] = 'http://www.xavyx.com';//http://yourdomain.com
$body['aps']['sound'] = 'default';
$body['aps']['badge'] = 0;
$body['aps']['action'] = 'xavyxComment';


//Setup stream (connect to Apple Push Server)
$passphrase = '';//passphrase if any
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
while($row = mysqli_fetch_array($result))
{
$apple_identifier = 'com.xavyx.xavyxapp';
$deviceToken = $row["token"];


 $log = new Logging();
 
 //set path and name of log file (optional)
$log->lfile('mylog.txt');
 
// write message to the log file
$log->lwrite('Error: '.$deviceToken);
 
// close log file
$log->lclose();


//echo "devicetoken ".$deviceToken."<br>";
$payload = json_encode($body);
            
// Enhanced Notification
$msg = pack("C", 1) . pack("N", $apple_identifier) . pack("N", $apple_expiry) . pack("n", 32) . pack('H*', str_replace(' ', '', $deviceToken)) . pack("n", strlen($payload)) . $payload; 
            
// SEND PUSH
fwrite($fp, $msg);

// We can check if an error has been returned while we are sending, but we also need to 
// check once more after we are done sending in case there was a delay with error response.
checkAppleErrorResponse($fp); 
}

// Workaround to check if there were any errors during the last seconds of sending.
// Pause for half a second. 
// Note I tested this with up to a 5 minute pause, and the error message was still available to be retrieved
usleep(500000); 

checkAppleErrorResponse($fp);

//echo 'Completed';
		print json_encode('Completed');

//mysqli_close($link);
fclose($fp);

}
}
}
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

