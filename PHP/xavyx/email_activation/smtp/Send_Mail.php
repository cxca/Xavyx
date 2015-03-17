<?php

function Send_Mail($to,$subject,$body)
{
if (!class_exists("phpmailer")) {
	require_once 'class.phpmailer.php';	
}
/*if(strpos(__FILE__,'/') != FALSE){
    chdir("..");
}*/
require_once($_SERVER['DOCUMENT_ROOT'].'/xavyx/email_activation/emailParams.php');

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
$mail->Subject    = $subject;
$mail->MsgHTML($body);
$address = $to;
$mail->AddAddress($address, $to);
//$mail->Send(); 
if(!$mail->send()) {
   echo 'Message could not be sent.';
   echo 'Mailer Error: ' . $mail->ErrorInfo;
   exit;
}
}

?>
