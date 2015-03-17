<?php
// sending email
if(strpos(__FILE__,'/') != FALSE){
    chdir("..");
}
include_once ('./db.php');
include_once './Encryptor.php';
require("./lib.php");

include 'smtp/Send_Mail.php';
require "emailParam.php";
	{
require 'smtp/class.phpmailer.php';
	
ini_set("smtp_port", $port);  
$from       = $username;
$mail       = new PHPMailer();
$mail->IsSMTP(true);            // use SMTP
//$mail->SMTPDebug = 1;
//Ask for HTML-friendly debug output
//$mail->Debugoutput = 'html';
$mail->IsHTML(true);
$mail->SMTPAuth   = true;                  // enable SMTP authentication
$mail->Mailer = "smtp";
$mail->SMTPSecure = "ssl";  
//$mail->SMTPSecure = 'tls';  
$mail->Host       = $host; // SMTP host
$mail->Port       = $port;                    // set the SMTP port
$mail->Username   = $username;  // SMTP  username
$mail->Password   = $password;  // SMTP password
$mail->SetFrom($from, $setFrom);
$mail->AddReplyTo($from,'');

$subject="Account activation re-sent";
$mail->Subject    = $subject;

//$mail->Send(); 

}
	
	$result = myquery("SELECT * FROM login WHERE status = '0'");
	
	while($row = mysql_fetch_assoc($result))
	{
		//$mail2 = clone $mail;
		
		$email = decrypt($row['email']);
		$activation = $row['activation'];
		$to=$email;
			//echo "email ".$to;
			//$to = "cchaparro@me.com";
			
			$body='Hi, <br/> <br/>
			Please click the following URL to verify your email and complete your account registration. <br/> <br/> <a href="'.$base_url.'activation/'.$activation.'">'.$base_url.'activation/'.$activation.'</a>
			<br/><br/>Account information entered but not activated will be automatically removed after 24 hours if the registration is not completed.
			<br/><br/>To ensure delivery to your inbox, add system@xavyx.com to your address book. 
			<br/>You are receiving this email from Xavyx.<br/>This is an automatically generated email. Please do not reply. ';
			$mail->MsgHTML($body);
			$address = decrypt($row['email']);
			$mail->AddAddress($address, $to);
			//Send_Mail($to,$subject,$body);
			//echo "Activation sent";
			//echo "email ".$email;
			//sleep(3);
			if(!$mail->send()) {
			   echo 'Message could not be sent.';
			   echo 'Mailer Error: ' . $mail->ErrorInfo;
			   exit;
			}
			else
			{
				echo 'Message sent.';
			}
	}
	
	//echo "Activations sents: ".mysql_num_rows($result);

?>


