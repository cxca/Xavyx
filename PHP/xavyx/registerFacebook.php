<?php
include 'db.php';
include 'Encryptor.php';
$msg='';


	$encryptedEmail = $email;
	$encryptedPassword = $pass;
	
	
	$email = decrypt($email);
	$email = clean($email);

	$regex = '/^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*(\.[a-z]{2,4})$/';
	
	if(preg_match($regex, $email))
	{ 
		$count = myquery("SELECT IdUser FROM login WHERE email='$encryptedEmail'");
		
		// email check
		if(mysqli_num_rows($count) < 1)
		{
		
			$result = query("INSERT INTO login(email, pass, firstName, lastName, status) VALUES('$encryptedEmail', '$pass', '$firstName','$lastName', '1')");
			if ($result['error']) {
				//for some database reason the registration is unsuccessfull
				errorJson('Registration failed email '.$email.' fName '.$firstName);
			}			
		
			$array = array(
				"code" => "1",
				"MSG" => "Registration successful",
			);
		
				print json_encode($array);
				$msg= "Registration successful";	

		}
		else
		{
			$array = array(
				"code" => "2",
				"MSG" => "Already Registered",
			);
		
				print json_encode($array);
				$msg= '<font color="#cc0000">Already registered.</font>';	

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


function clean($string) {
   $string = str_replace(' ', '', $string); // Replaces all spaces with hyphens.
   return preg_replace('/[^A-Za-z0-9!@.\-]/', '', $string); // Removes special chars.
}

?>

