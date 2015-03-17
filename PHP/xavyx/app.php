<?
/* iReporter complete web demo project
 *
 * index.php takes care to check the "command" request
 * and call the proper API function to process the user request
 * 
 */
 
// this line starts the server session - that means the server will "remember" the user
// between different API calls - ie. once the user is authorized, he will stay logged in for a while
session_start();

// the requre lines include the lib and api source files
require("lib.php");
require("api.php");

// this instructs the client (in this case the iPhone app) 
// that the server will output JSON data
header("Content-Type: application/json");

// the iPhone app sends over what "command" of the API it wants executed
// the tutorial covers "login","register","upload", "logout" and "stream"
// so using a switch statement for this taks makes most sense

// the functions you call inside the switch are found in the api.php file
switch ($_POST['command']) {
	case "login":
		login($_POST['email'], $_POST['password']); 
		break;
	case "reLogin":
		reLogin($_POST['email'], $_POST['password']); 
		break;
 
	case "register":
		register($_POST['email'], $_POST['password'], $_POST['firstName'],  $_POST['lastName']); 
		break;
 
	case "upload":
		upload($_SESSION['IdUser'], $_FILES['file'], $_POST['title']);
		break;
	case "canUpload":
		canUpload($_SESSION['IdUser']);
		break;
		
	case "logout":
		logout();
		break;

	case "stream":
		stream($_SESSION['IdUser'], $_POST['IdPhoto'],(int)$_POST['offset'],(int)$_POST['streamType']);
		break;
	case "streamMyUploads":
		streamMyUploads($_SESSION['IdUser'],(int)$_POST['offset'],(int)$_POST['streamType']);
		break;
		
	case "uploadProfilePicture":
		uploadProfilePicture($_SESSION['IdUser'], $_FILES['file']);
		break;
	case "forgotPassword":
		resetPassword($_POST['email']);
		break;
		
	case "like":
		like($_POST['idPhoto'], $_SESSION['IdUser']);
		break;
	case "unlike":
		unlike($_POST['idPhoto'], $_SESSION['IdUser']);
		break;

	case "flag":
		flag($_POST['idPhoto'], $_SESSION['IdUser'],$_POST['type']);
		break;
		
	case "deletePhoto":
		deletePhoto($_POST['idPhoto'], $_SESSION['IdUser']);
		break;
		
	case "dateTime":
		currentDateTime();
		break;
	case "amountOfLife":
		increaseLife();
		break;

	case "deleteAccount":
		deleteAccount($_SESSION['IdUser']);
		break;
	case "confirmPassword":
		confirmPassword($_SESSION['IdUser'], $_POST['password']);
		break;
		
	//Comments
	case "commentsCount":
		commentsCount($_SESSION['IdUser'], $_POST['IdPhoto'], $offset);
		break;
	case "commentsFetch":
		commentsFetch($_SESSION['IdUser'], $_POST['IdPhoto'], $_POST['offset']);
		break;
	case "commentInsert":
		commentInsert($_SESSION['IdUser'], $_POST['IdPhoto'], $_POST['comment']);
		break;
	case "checkConversation":
		checkConversation($_SESSION['IdUser'], $_POST['IdPhoto']); 
		break;		
	case "joinConversation":
		joinConversation($_SESSION['IdUser'], $_POST['IdPhoto']); 
		break;
	case "removeConversation":
		removeConversation($_SESSION['IdUser'], $_POST['IdPhoto']); 
		break;
	
	//Notification
	case "notificationFetch":
		notificationFetch($_SESSION['IdUser']);
		break;
	case "fetchSpecific":
		fetchSpecific( $_POST['type'], $_POST['IdPhoto']);
		break;
	
	//Facebook
	case "registerFacebook":
		registerFacebook($_POST['email'], $_POST['password'], $_POST['firstName'],  $_POST['lastName']); 
		break;	
	
	}
	
	
	
// this line is redundant as the file ends anyway, 
// but just making sure no more code gets executed
exit();