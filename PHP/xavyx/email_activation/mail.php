<?php
if(strpos(__FILE__,'/') != FALSE){
    chdir("..");
}
include_once ('./db.php');
include_once './Encryptor.php';
$msg='';

//if(!empty($_POST['email']) && isset($_POST['email']) &&  !empty($_POST['password']) &&  isset($_POST['password']) )
{
	// username and password sent from form
	/*
	$email=mysqli_real_escape_string($connection,$_POST['email']);
	$password=mysqli_real_escape_string($connection,$_POST['password']);
	*/
	$encryptedEmail = $email;
	$encryptedPassword = $pass;
	
	
	$email = decrypt($email);
	$email = clean($email);

	//$email=mysqli_real_escape_string($connection,$email);
	//errorJson('Email: '.$email);
	//$password=mysqli_real_escape_string($connection,$pass);
	// regular expression for email check
	$regex = '/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/';
	
	if(preg_match($regex, $email))
	{ 
		//$password=md5($password); // encrypted password
		$activation=md5($email.time()); // encrypted email+timestamp		
  
		$count = myquery("SELECT IdUser FROM login WHERE email='$encryptedEmail'");
			
		// email check
		if(mysqli_num_rows($count) < 1)
		{
		
			$result = query("INSERT INTO login(email,pass,activation, firstName, lastName) VALUES('$encryptedEmail','$encryptedPassword','$activation','$firstName','$lastName')");

			if ($result['error']) {
				//for some database reason the registration is unsuccessfull
				errorJson('Registration failed');
			}

			// sending email
			include 'smtp/Send_Mail.php';
			
			global $base_url;
			$to=$email;
			//$to = $email;
			$subject="Account activation";
			$body='Hi, <br/> <br/>
			Please click the following URL to verify your email and complete your account registration. <br/> <br/> <a href="'.$base_url.'activation/'.$activation.'">'.$base_url.'activation/'.$activation.'</a>
			<br/><br/>Account information entered but not activated will be automatically removed after 24 hours if the registration is not completed.
			<br/><br/>To ensure delivery to your inbox, add system@xavyx.com to your address book. 
			<br/>You are receiving this email from Xavyx.<br/>This is an automatically generated email. Please do not reply. ';
			
			Send_Mail($to,$subject,$body);
			$array = array(
				"code" => "1",
				"MSG" => "Registration successful, please activate email.",
			);
		
				print json_encode($array);
				$msg= "Registration successful, please activate email.";	

		}
		else
		{
			$array = array(
				"code" => "2",
				"MSG" => "The email is already taken, please try new.",
			);
		
				print json_encode($array);
				$msg= '<font color="#cc0000">The email is already taken, please try new.</font>';	

		}
	
	}
	else
	{
		$array = array(
				"code" => "0",
				"MSG" => "The email you have entered is invalid, please try again.",
			);
		
				print json_encode($array);
			   $msg = '<font color="#cc0000">The email you have entered is invalid, please try again.</font>';  

	}

}
function clean($string) {
   $string = str_replace(' ', '', $string); // Replaces all spaces with hyphens.
   return preg_replace('/[^A-Za-z0-9!@.\-]/', '', $string); // Removes special chars.
}
?>

