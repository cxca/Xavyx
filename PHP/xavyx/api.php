<?

// helper function, which outputs error messages in JSON format
// so that the iPhone app can read them
// the function just takes in a dictionary with one key "error" and 
// encodes it in JSON, then prints it out and then exits the program
function errorJson($msg){
	print json_encode(array('error'=>$msg));
	exit();
}

// register API
function register($email, $pass, $firstName, $lastName) {

	global $link;

	$email = mysqli_real_escape_string($link, $email);
	$pass = mysqli_real_escape_string($link, $pass);
	$firstName = mysqli_real_escape_string($link, $firstName);
	$lastName = mysqli_real_escape_string($link, $lastName);

	//check if username exists in the database (inside the "login" table)

	include 'email_activation/mail.php';

}

//login API
function login($user, $pass) {
	
	global $link;

	$user = mysqli_real_escape_string($link, $user);
	$pass = mysqli_real_escape_string($link, $pass);

	// try to match a row in the "login" table for the given username and password
	$result = query("SELECT IdUser, firstName, lastName FROM login WHERE email='$user' AND pass='$pass' AND status='1' limit 1");//Change status to 0 = only who confirm email will be given access
	 $ip = $_SERVER['REMOTE_ADDR'];

	if (count($result['result'])>0) {
				// a row was found in the database for username/pass combination
				// save a simple flag in the user session, so the server remembers that the user is authorized
				$_SESSION['IdUser'] = $result['result'][0]['IdUser'];
				$IdUser = $result['result'][0]['IdUser'];
				
			include 'Encryptor.php';

		//Activity log
			$comment = "Log in success";
			if(decrypt($pass) == "Facebook")
				$comment = "Log in success (Facebook)";
			$type = "Log In";
			query("INSERT INTO activityLog(type, comment, ip, IdUser) VALUES('$type', '$comment', '$ip', '$IdUser')"); 
	
	
	$firstName = $result['result'][0]['firstName'];
	$lastName = $result['result'][0]['lastName'];
		$array = array(
			"firstName" => $firstName,
			"lastName" => $lastName,
			"udid" => $IdUser,
		);
				print json_encode($array);

				//errorJson('Authorization failed');
			} else {
			// no matching username/password was found in the login table
			//Activity log
				$comment = "Log in failed";
				$type = "Log In";
				query("INSERT INTO activityLog(comment, type, ip) VALUES('$comment','$type', '$ip')"); 
				
			errorJson('Authorization failed');
	}
	
}

//Re - login API
function reLogin($user, $pass) {
	
	global $link;

	$user = mysqli_real_escape_string($link, $user);
	$pass = mysqli_real_escape_string($link, $pass);

	// try to match a row in the "login" table for the given username and password
	$result = query("SELECT IdUser, firstName, lastName FROM login WHERE email='$user' AND pass='$pass' AND status='1' limit 1");
	 $ip = $_SERVER['REMOTE_ADDR'];

	if (count($result['result'])>0) {
				// a row was found in the database for username/pass combination
				// save a simple flag in the user session, so the server remembers that the user is authorized
				$_SESSION['IdUser'] = $result['result'][0]['IdUser'];
				$IdUser = $result['result'][0]['IdUser'];
				

	$firstName = $result['result'][0]['firstName'];
	$lastName = $result['result'][0]['lastName'];
		$array = array(
			"firstName" => $firstName,
			"lastName" => $lastName,
			"udid" => $IdUser,
		);
				print json_encode($array);

				//errorJson('Authorization failed');
			} else {
			// no matching username/password was found in the login table

				
			errorJson('Authorization failed');
	}
	
}
//Can Upload API
function canUpload($id) {
 //If 24 hour later
 
if (!$id) errorJson('Authorization required');
		
		
 		$result = myquery("SELECT transactionDateTime FROM photos WHERE IdUser='".$_SESSION['IdUser']."' ORDER BY transactionDateTime DESC limit 6");
 		
 //		if (count($result['result'])<6) 
 
 			// a row was found in the database for username/pass combination
 			$currentDateTime = date('Y-m-d H:i:s');
 			$count = 0;

 			while($row=mysqli_fetch_assoc($result))
 			{
 				$lastUploadedDateTime = strtotime('+1 day', $row['transactionDateTime']);
 				if($lastUploadedDateTime > $currentDateTime)
 				{
 					$count++;
 				}
 		
 			}
 			
 			if($count<6)
 			{
 				$array = array(
 					"Success" => "",
 				);
 				
 				print json_encode($array);
 			}
 			else
 				errorJson('Cannot upload more photos');
 }
 
//upload API
function upload($id, $photoData, $title) {

	// index.php passes as first parameter to this function $_SESSION['IdUser']
	// $_SESSION['IdUser'] should contain the user id, if the user has already been authorized
	// remember? you store the user id there in the login function
	if (!$id) errorJson('Authorization required');
 
	// check if there was no error during the file upload
	if ($photoData['error']==0) {
	
		//If 24 hour later
		$result = myquery("SELECT transactionDateTime FROM photos WHERE IdUser='".$_SESSION['IdUser']."' ORDER BY transactionDateTime DESC limit 6");
		
//		if (count($result['result'])<6) 

			// a row was found in the database for username/pass combination
			$currentDateTime = date('Y-m-d H:i:s');
			$count = 0;
			
			while($row=mysqli_fetch_assoc($result))
			{
				$lastUploadedDateTime = strtotime('+1 day', $row['transactionDateTime']);
				if($currentDateTime < $lastUploadedDateTime)
				{
				}
				else
					$count++;
			}
			
			if($count<5)
			{
			// fetch the active connection to the database (it's initialized automatically in lib.php)
				global $link;
				
				// get the last automatically generated ID in the photos table

				$IdPhoto = mysqli_insert_id($link);
				$IdPhoto = $_SESSION['IdUser']."".strtotime("now");//date('Y-m-d h:i:s');
					// insert the details about the photo to the "photos" table
					
					//picture life
				 $date = date("Y-m-d H:i:s");
				$currentDate = strtotime($date);
				$futureDate = $currentDate+(60*60*24*7);//Sec * Min * Hour *days
				$formatDate = date("Y-m-d H:i:s", $futureDate);
				
				//Check string
				$title = mysqli_real_escape_string($link, $title);

				$result = query("INSERT INTO photos(IdUser, IdPhoto, life, title) VALUES('%d','%s','$formatDate', '$title')", $id, $IdPhoto, $title);
				if (!$result['error']) {
		 
				//Upload success
				
				
				  if ( move_uploaded_file( $_FILES['file']['tmp_name'],  "upload/".$IdPhoto.".jpg" ) )
					{
						// the file has been moved correctly
						//thumb("../upload/".$IdPhoto."jpg", 180);
						//rename('../upload/'.$IdPhoto.'-thumb.jpg', '../upload/thumb/'.$IdPhoto.'-thumb.jpg');
						
						//Activity log
							$comment = "Uploaded public picture";
							$type = "Picture";
							$ip = $_SERVER['REMOTE_ADDR'];
							query("INSERT INTO activityLog(type, comment, ip, IdUser) VALUES('$type', '$comment', '$ip', '$id')"); 
							
						$array = array(
							"Success" => $title,
 						);
						//print json_encode(array('successful'=>1));
					  print json_encode($array);
					}
					else
						errorJson('Upload server problem');
		 
				} else {
					errorJson('Upload database problem.'.$result['error']);
				}
					
			}
			
			else 
			{
				// no matching username/password was found in the login table
				errorJson('You already uploaded the pictures. You\'ll have to wait the next 24 hour cycle.');
			}
			
		
	}
	
}

//upload Profile Picture API
function uploadProfilePicture($IdUser, $photoData) {

	// index.php passes as first parameter to this function $_SESSION['IdUser']
	// $_SESSION['IdUser'] should contain the user id, if the user has already been authorized
	// remember? you store the user id there in the login function
	if (!$IdUser) errorJson('Authorization required');
 
	// check if there was no error during the file upload
	if ($photoData['error']==0) {
			
	// fetch the active connection to the database (it's initialized automatically in lib.php)
	global $link;


	  //Upload success
				
	  if ( move_uploaded_file( $_FILES['file']['tmp_name'],  "profile/".$IdUser.".jpg" ) )
		{
			// the file has been moved correctly
			//thumb("../upload/".$IdPhoto."jpg", 180);
			//rename('../upload/'.$IdPhoto.'-thumb.jpg', '../upload/thumb/'.$IdPhoto.'-thumb.jpg');
			//Activity log
				$comment = "Uploaded profile picture";
				$type = "Profile";
				$ip = $_SERVER['REMOTE_ADDR'];
				query("INSERT INTO activityLog(type, comment, ip, IdUser) VALUES('$type', '$comment', '$ip', '$IdUser')"); 
			$array = array(
				"Success" => "",
			);
			//print json_encode(array('successful'=>1));
		  print json_encode($array);
		}
		else
			errorJson('Upload server problem');
	}
				  
}

//logout API
function logout() {

	// by saving an empty array to $_SESSION you are
	// effectively destroying all the user session data
	// ie. the server won't "remember" anymore anything about
	// the current user
	$_SESSION = array();
	
	// and to make double-sure, there's also a built-in function 
	// which wipes out the user session
	session_destroy();
}

//stream API
//
// there are 2 ways to use the function:
// 1) don't pass any parameters - then the function will fetch all photos from the database
// 2) pass a photo id as a parameter - then the function will fetch the data of the requested photo
//
// Q: what "$IdPhoto=0" means? A: It's the PHP way to say "first param of the function is $IdPhoto, 
// if there's no param sent to the function - initialize $IdPhoto with a default value of 0"
function stream($IdUser,$IdPhoto=0, $offset, $type) {

if (!$IdUser) errorJson('Authorization required');

	if ($IdPhoto==0) 
	{

	$IdUser = $_SESSION['IdUser'];
		switch ($type){
			case 0:
				$result = query("SELECT p.title, p.IdPhoto, p.transactionDateTime, p.life, p.likes,p.flags , l.IdUser, l.firstName, l.lastName, 
				IFNULL(k.liked,'0') AS liked, IFNULL(f.flagged,'0') AS flagged
								FROM photos p 
								 JOIN login l ON (l.IdUser = p.IdUser)
								 LEFT JOIN likes k ON (k.IdUser = '$IdUser' AND k.IdPhoto = p.IdPhoto)
								   LEFT JOIN flag f ON (f.IdUser = '$IdUser' AND f.IdPhoto = p.IdPhoto)			
								    WHERE p.active = '1' AND f.flagged is null
									 ORDER BY transactionDateTime DESC LIMIT 50 OFFSET $offset");
									 
			
				break;
			case 1:	
				$result = query("SELECT p.title, p.IdPhoto, p.transactionDateTime, p.life, p.likes,p.flags, l.IdUser, l.firstName, l.lastName, 
				IFNULL(k.liked,'0') AS liked, IFNULL(f.flagged,'0') AS flagged
								FROM photos p 
								 JOIN login l ON (l.IdUser = p.IdUser)
								  LEFT JOIN likes k ON (k.IdUser = p.IdUser AND k.IdPhoto = p.IdPhoto)
								   LEFT JOIN flag f ON (f.IdUser = p.IdUser AND f.IdPhoto = p.IdPhoto)								   
								    WHERE p.active = '1' AND f.flagged is null
									 ORDER BY life DESC LIMIT 50 OFFSET $offset");
				break;
		}
		
		//Likes and flags table

	} 
 
	if (!$result['error']) {
		// if no error occured, print out the JSON data of the 
		// fetched photo data
		print json_encode($result);
		
	} else {
		//there was an error, print out to the iPhone app
		errorJson('Photo stream is broken');
	}
	
}


//stream my recent upload API
//
// 1) pass IdUser - then all photo from the user will fetch from database
function streamMyUploads($IdUser, $offset, $type) {
if (!$IdUser) errorJson('Authorization required');

	switch ($type){
			case 0:
				$result = query("SELECT p.title, p.IdPhoto, p.transactionDateTime, p.life, p.likes,p.flags , l.IdUser, l.firstName, l.lastName
								FROM photos p 
								 JOIN login l ON (l.IdUser = p.IdUser)		
								    WHERE p.active = '1' AND p.IdUser='$IdUser'
									 ORDER BY IdPhoto DESC LIMIT 50 OFFSET $offset");
									 
			
				break;
			case 1:	
				$result = query("SELECT p.title, p.IdPhoto, p.transactionDateTime, p.life, p.likes,p.flags, l.IdUser, l.firstName, l.lastName
								FROM photos p 
								 JOIN login l ON (l.IdUser = p.IdUser)							   
								    WHERE p.active = '1' AND p.IdUser='$IdUser'
									 ORDER BY life DESC LIMIT 50 OFFSET $offset");
				break;
		}
		
	if (!$result['error']) {
		// if no error occured, print out the JSON data of the 
		// fetched photo data
		print json_encode($result);
		
	} else {
		//there was an error, print out to the iPhone app
		errorJson('Photo stream is broken');
	}
 
	
}

//Reset Password API
//
// 1) pass email - then send verification token
function resetPassword($email) {

	global $link;

	$email = mysqli_real_escape_string($link, $email);

$emailLocal = $email;

	//Log reset password
	$ip = $_SERVER['REMOTE_ADDR'];
	
	$result = myquery("SELECT attempts, transactionDateTime FROM forgotPassword WHERE email='$emailLocal' AND ip='$ip' ORDER BY attempts DESC limit 1");
	
	$attempts = 1;
	$continue = true;
	if(mysqli_num_rows($result)>0)
	{
		$fetch = mysqli_fetch_assoc($result);
		$attempts = $fetch['attempts'];
		$date = $fetch['transactionDateTime'];
		
		$date2 = explode(' ', $date);
		$date = $date2[0];
		$attempts = $attempts + 1;
		
		if($attempts > 5 && date('Y-m-d') == $date)
		{
			$continue = false;
			
		}
		else{
			include 'resetPassword/mailReset.php';
		}
		
	}
	
	if($continue == true)
		query("INSERT INTO forgotPassword(ip,email,attempts) VALUES('$ip','$emailLocal', '$attempts')"); 

}

function like($IdPhoto, $IdUser)
{
if (!$IdUser) errorJson('Authorization required');

	//Log reset password
	$ip = $_SERVER['REMOTE_ADDR'];
	
	$result = myquery("SELECT id FROM likes WHERE IdPhoto='$IdPhoto' AND IdUser='$IdUser' limit 1");
	if(mysqli_num_rows($result)==0)
	{
	
		$result = myquery("SELECT life FROM photos WHERE IdPhoto='$IdPhoto'");
		if($row = mysqli_fetch_assoc($result))
		{
			if(date('Y-m-d H:i:s') < $row['life'])
			{
				myquery("INSERT INTO likes(IdUser,IdPhoto) VALUES('$IdUser','$IdPhoto')");
				
				//Increment likes in photo
				$result = myquery("SELECT id FROM likes WHERE IdPhoto='$IdPhoto'");
				$nr = mysqli_num_rows($result);
				//$nr++;
				
				$date = strtotime($row['life']);
				$futureDate = $date + (60*60*5);
				$formatDate = date("Y-m-d H:i:s", $futureDate);
				myquery("UPDATE photos SET likes='$nr', life ='$formatDate' WHERE IdPhoto='$IdPhoto'");
			}
		}
	
	}

}

function unlike($IdPhoto, $IdUser)
{
if (!$IdUser) errorJson('Authorization required');

	//Log reset password
	$ip = $_SERVER['REMOTE_ADDR'];
	
	$result = myquery("SELECT id FROM likes WHERE IdPhoto='$IdPhoto' AND IdUser='$IdUser' limit 1");
	if(mysqli_num_rows($result)>0)
	{
	
		$result = myquery("SELECT life FROM photos WHERE IdPhoto='$IdPhoto'");
		if($row = mysqli_fetch_assoc($result))
		{
			if(date('Y-m-d H:i:s') < $row['life'])
			{
				myquery("DELETE FROM likes WHERE IdUser = '$IdUser' && IdPhoto = '$IdPhoto'");
				
				//Increment likes in photo
				$result = myquery("SELECT id FROM likes WHERE IdPhoto='$IdPhoto'");
				$nr = mysqli_num_rows($result);
				//$nr++;
				
				$date = strtotime($row['life']);
				$futureDate = $date - (60*60*5);
				$formatDate = date("Y-m-d H:i:s", $futureDate);
				myquery("UPDATE photos SET likes='$nr', life ='$formatDate' WHERE IdPhoto='$IdPhoto'");
			}
		}
	
	}

}

function flag($IdPhoto, $IdUser, $type)
{
if (!$IdUser) errorJson('Authorization required');

	//Log reset password
	$ip = $_SERVER['REMOTE_ADDR'];
	
	$result = myquery("SELECT id FROM flag WHERE IdPhoto='$IdPhoto' AND IdUser='$IdUser' limit 1");
	if(mysqli_num_rows($result)==0)
	{
		myquery("INSERT INTO flag(IdUser,IdPhoto, type) VALUES('$IdUser','$IdPhoto', '$type')");
		
		//Increment likes in photo
		$result = myquery("SELECT id FROM flag WHERE IdPhoto='$IdPhoto'");
		$nr = mysqli_num_rows($result);
		//$nr++;
		
		
		//Check if flags are greater than 20 and > likes/2
		$result = myquery("SELECT id FROM likes WHERE IdPhoto='$IdPhoto'");
		$nrLikes = mysqli_num_rows($result);
		if($nr > 20 && $nr > $nrLikes/2)
		{
			//Set active =0
			myquery("UPDATE photos SET active='0', flags='$nr' WHERE IdPhoto='$IdPhoto'");
			myquery("INSERT INTO flagDeletedPhotos SELECT * FROM photos WHERE IdPhoto='$IdPhoto'");
			
			
		
		}
		else
			mysqli_query("UPDATE photos SET flags='$nr' WHERE IdPhoto='$IdPhoto'");
		
	}

}

//Delete photo API
function deletePhoto($IdPhoto, $IdUser)
{
	if (!$IdUser) errorJson('Authorization required');
	

	//Select IdPhoto from active picture		
	$result = myquery("Select IdPhoto FROM photos WHERE active = '1' AND IdUser = '$IdUser' AND IdPhoto = '$IdPhoto'");
	if($row = mysqli_fetch_assoc($result))
	{
		unlink("../upload/".$row['IdPhoto'].".jpg");
		query("DELETE FROM photos WHERE IdPhoto = '$IdPhoto'");
		query("DELETE FROM photoComments WHERE IdPhoto = '$IdPhoto'");
		
		$array = array(
				"Success" =>'',
			);
 				
		print json_encode($array);
	}
	else
		errorJson('Cound not proceed');
		



}



function currentDateTime()
{
	$array = array(
 					"dateTime" => date('Y-m-d H:i:s'),
 				);
 				
 				print json_encode($array);
}

function increaseLife()
{
	$seconds = 60*60*5;
	$array = array(
 					"seconds" => $seconds,
 				);
 				
 				print json_encode($array);
 				
}

///
///
//Delete Profile API
function deleteAccount($IdUser)
{
	if (!$IdUser) errorJson('Authorization required');
		
//Select IdPhoto from active picture		
	$result = myquery("SELECT IdPhoto FROM photos WHERE active = '1' AND IdUser = '$IdUser'");
	while($row = mysqli_fetch_assoc($result))
	{
		unlink("../upload/".$row['IdPhoto'].".jpg");
		unlink("../profile/".$IdUser.".jpg");
	
	}
	
//	Delete All Pictures for IdUser
	query("DELETE FROM photos WHERE active = '1' AND IdUser = '$IdUser'");
	
//	Delete likes and flags	
	query("DELETE FROM likes WHERE IdUser = '$IdUser'");
	query("DELETE FROM flag WHERE IdUser = '$IdUser'");
	
//	Delete from login
	query("DELETE FROM login WHERE IdUser = '$IdUser'");
	
	//Activity log
	$comment = "Deleted user account";
	$type = "Deleted Account";
	$ip = $_SERVER['REMOTE_ADDR'];
	query("INSERT INTO activityLog(type, comment, ip, IdUser) VALUES('$type', '$comment', '$ip', '$IdUser')"); 
						
	$array = array(
				"Success" =>'',
			);
 				
	print json_encode($array);


}

//API
//Confirm Password preview of account deletetion
function confirmPassword($IdUser, $pass)
{
	if (!$IdUser) errorJson('Authorization required');

	$result = myquery("SELECT IdUser FROM login WHERE status = '1' AND IdUser = '$IdUser' AND pass = '$pass'");
	$nr = mysqli_num_rows($result);
	if($nr == 1)
	{
		$array = array(
				"Success" =>''
			);
				print json_encode($array);

 	}
 	else
		errorJson('Cound not proceed');
	
}

//****Comments count******//
function commentsCount($IdUser, $IdPhoto)
{
	if (!$IdUser) errorJson('Authorization required');
	
	$result = myquery("SELECT id FROM photoComments WHERE IdPhoto = '$IdPhoto'");
	$nr = mysqli_num_rows($result);
	if($nr == null)
		$nr = 0;
	$array = array(
		"nr" => $nr,
		);
	print json_encode($array);
	
}
//****Comments fetch******//
function commentsFetch($IdUser, $IdPhoto, $offset)
{
	if (!$IdUser) errorJson('Authorization required');
//	$IdPhoto = mysqli_real_escape_string($link, $IdPhoto);
	//$offset = mysqli_real_escape_string($link, $offset);

	$result = query("SELECT p.comment, p.transactionDateTime, l.IdUser, l.firstName, l.lastName FROM photoComments p 
					JOIN login l ON (l.IdUser = p.IdUser)	
					WHERE p.IdPhoto = '$IdPhoto' ORDER BY p.transactionDateTime DESC LIMIT 20 OFFSET $offset");
	
	//if (!$result['error']) {
		// if no error occured, print out the JSON data of the 
		// fetched photo data
		print json_encode($result);
		
	//} else {
		//there was an error, print out to the iPhone app
	//	errorJson('Photo stream is broken');
//	}
}
//****Comment Insert****//
function commentInsert($IdUser, $IdPhoto, $comment)
{
	if (!$IdUser) errorJson('Authorization required');
	
	// fetch the active connection to the database (it's initialized automatically in lib.php)
	global $link;
	$comment = mysqli_real_escape_string($link, $comment);
	//ob_end_flush();
	$ip = $_SERVER['REMOTE_ADDR'];
	$result = query("INSERT INTO photoComments(IdPhoto, IdUser, comment, ip) VALUES('$IdPhoto', '$IdUser', '$comment', '$ip')"); 
	//if (!$result['error']) 
		print json_encode($result);
	//else
	//	errorJson('Could not save comment');
	
	
	//APNS notification
	require 'apnsPhotoComments.php';
}
//Check if joined conversation
function checkConversation($IdUser, $IdPhoto)
{
	if (!$IdUser) errorJson('Authorization required');
	
	$result = myquery("SELECT id FROM photoCommentsAPNS WHERE IdUser = '$IdUser' AND IdPhoto = '$IdPhoto'");
	$nr = mysqli_num_rows($result);
	if($nr == null)
		$nr = 0;
	$array = array(
		"nr" => $nr,
		);
	print json_encode($array);

}
function joinConversation($IdUser, $IdPhoto)
{
	if (!$IdUser) errorJson('Authorization required');
	
	// fetch the active connection to the database (it's initialized automatically in lib.php)
	global $link;
	$IdPhoto = mysqli_real_escape_string($link, $IdPhoto);

	$ip = $_SERVER['REMOTE_ADDR'];
	$result = query("INSERT INTO photoCommentsAPNS(IdPhoto, IdUser) VALUES('$IdPhoto', '$IdUser')"); 
	//if (!$result['error']) 
		print json_encode($result);
	//else
	//	errorJson('Could not save comment');

}
function removeConversation($IdUser, $IdPhoto)
{
	if (!$IdUser) errorJson('Authorization required');

	$result = query("DELETE FROM photoCommentsAPNS WHERE IdUser = '$IdUser' AND IdPhoto = '$IdPhoto'");
	//if (!$result['error']) 
		print json_encode($result);
	//else
	//	errorJson('Could not save comment');
}

//Notification
function notificationFetch($IdUser)
{
	if (!$IdUser) errorJson('Authorization required');

	$result = query("SELECT n.id, n.IdPhoto, n.message, n.type, n.status, n.transactionDateTime, l.IdUser, l.firstName, l.lastName, l.profileImage FROM notifications n
					JOIN login l ON (l.IdUser = n.IdUser)
					WHERE n.IdUser = '$IdUser' ORDER BY n.transactionDateTime DESC LIMIT 20");
	
	if (!$result['error']) {
		// if no error occured, print out the JSON data of the 
		print json_encode($result);
		
	} else {
		//there was an error, print out to the iPhone app
		errorJson('Notifications stream is broken');
	}

}

function fetchSpecific($type, $IdPhoto)
{
	if($type == "photoComment")
	{
		$result = query("SELECT p.title, p.IdPhoto, p.transactionDateTime, p.life, p.likes,p.flags , l.IdUser, l.firstName, l.lastName, 
				IFNULL(k.liked,'0') AS liked, IFNULL(f.flagged,'0') AS flagged
								FROM photos p 
								 JOIN login l ON (l.IdUser = p.IdUser)
								 LEFT JOIN likes k ON (k.IdUser = '$IdUser' AND k.IdPhoto = p.IdPhoto)
								   LEFT JOIN flag f ON (f.IdUser = '$IdUser' AND f.IdPhoto = p.IdPhoto)			
								    WHERE p.IdPhoto = '$IdPhoto'
									  LIMIT 1");
		
		if (!$result['error']) {
			// if no error occured, print out the JSON data of the 
			print json_encode($result);
			
		} else {
			//there was an error, print out to the iPhone app
			errorJson('Notifications stream is broken');
		}
	}

}


//Login with facebook
function registerFacebook($email, $pass, $firstName, $lastName)
{
	global $link;

	$firstName = mysqli_real_escape_string($link, $firstName);
	$lastName = mysqli_real_escape_string($link, $lastName);
	$pass = mysqli_real_escape_string($link, $pass);
	$email = mysqli_real_escape_string($link, $email);

	include 'registerFacebook.php';
}