<?php
function Send_Mail($to,$subject,$body)
{

require_once($_SERVER['DOCUMENT_ROOT'].'/xavyx/email_activation/emailParams.php');
//global $username;
//global $password;
//global $setFrom;
//global $port;
//global $host;

require 'class.phpmailer.php';
$from       = $username;
$mail       = new PHPMailer();
$mail->IsSMTP(true);            // use SMTP
$mail->IsHTML(true);
$mail->SMTPAuth   = true;                  // enable SMTP authentication
$mail->Mailer = "smtp";
$mail->Host       = "tls://".$host; // SMTP host
$mail->Port       =  $port;                    // set the SMTP port
$mail->Username   = $username;  // SMTP  username
$mail->Password   = $password;  // SMTP password
$mail->SetFrom($from, $setFrom);
$mail->AddReplyTo($from,'');
$mail->Subject    = $subject;
$mail->MsgHTML($body);
$address = $to;
$mail->AddAddress($address, $to);
$mail->Send(); 
}
?>