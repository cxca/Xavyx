<?php
if(strpos(__FILE__,'/') != FALSE){
    chdir("..");
}
require_once ('./db.php');
require_once './Encryptor.php';

$msg='';

if(!empty($_POST['email']) && isset($_POST['email']))
{
	// username and password sent from form
	/*
	$email=mysqli_real_escape_string($connection,$_POST['email']);
	$password=mysqli_real_escape_string($connection,$_POST['password']);
	*/
	$encryptedEmail = $email;
	//$encryptedPassword = $pass;
	
	
	$email = decrypt($email);
	$email = clean($email);
	
	//$email=mysqli_real_escape_string($connection,$email);
	//errorJson('Email: '.$email);
	//$password=mysqli_real_escape_string($connection,$pass);
	// regular expression for email check
	$regex = '/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/';
	
	if(preg_match($regex, $email))
	{ 
	global $path;
	global $domain;

		//$password=md5($password); // encrypted password
		$activation=md5($email.time()); // encrypted email+timestamp
		
  		$link =  @mysqli_connect(DB_SERVER,DB_USERNAME,DB_PASSWORD) or die(mysqli_error($link));
		mysqli_select_db($link, DB_DATABASE);

		$result = mysqli_query($link, "SELECT IdUser FROM login WHERE email='$encryptedEmail'");
		
		// email check
		if(mysqli_num_rows($result) == 1)
		{
		
			$result = query("UPDATE login SET activation='$activation' WHERE email='$encryptedEmail'");
			//$result = query("INSERT INTO login(email,pass,activation) VALUES('$email','$password','$activation')");
			//errorJson('Result: '.$result['error']);
			//if ($result['error']) {
				//for some database reason the registration is unsuccessfull
			//	errorJson('Registration failed');
			//}

			// sending email
			include 'smtp/Send_Mail.php';
			
			$base_url='http://'.$domain.'/'.$path.'/resetPassword/';
			$to=$email;
			//$to = $email;
			$subject="Account password reset";
							
			$body='Hi, <br/> <br/>
			Please click the following URL to verify your email and to be able to reset your password. <br/> <br/> <a href="'.$base_url.'activation/'.$activation.'">'.$base_url.'reset/'.$activation.'</a>
			<br/><br/>If you received this message in error, ignore.
			<br/>You are receiving this email from Xavyx.<br/>This is an automatically generated email. Please do not reply. ';
			
			Send_Mail($to,$subject,$body);
			$array = array(
				"code" => "1",
				"MSG" => "Password reset successfully.",
			);
		
				print json_encode($array);
				$msg= "Password reset successfully.";	

		}
		else
		{
			$array = array(
				"code" => "2",
				"MSG" => "Error",
			);
		
				print json_encode($array);
				$msg= '<font color="#cc0000">Error.</font>';	

		}
	
	}
	else
	{
		$array = array(
				"code" => "0",
				"MSG" => "The email you have entered is invalid, please try again.",
			);
		
				print json_encode($array);
			   $msg = '<font color="#cc0000">Error.</font>';  

	}

}
function clean($string) {
   $string = str_replace(' ', '', $string); // Replaces all spaces with hyphens.
   return preg_replace('/[^A-Za-z0-9!@.\-]/', '', $string); // Removes special chars.
}

?>

