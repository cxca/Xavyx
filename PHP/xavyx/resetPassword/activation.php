<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Xavyx</title>
<!--<link rel="stylesheet" href="style.css"/>-->
<link href="bootstrap/css/bootstrap.min.css" rel="stylesheet">
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="bootstrap/js/bootstrap.min.js"></script>
    
    <!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css">

<!-- Optional theme -->
<link rel="stylesheet" href="//netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap-theme.min.css">

<!-- Latest compiled and minified JavaScript -->
<script src="//netdna.bootstrapcdn.com/bootstrap/3.1.1/js/bootstrap.min.js"></script>

</head>
<?php
//if(strpos(__FILE__,'/') != FALSE){
//    chdir("..");
//}
chdir("..");
require_once './db.php';
require_once './Encryptor.php';

$msg='';
$base_url='http://'.$domain.'/'.$path.'/resetPassword/';
if(!empty($_POST['code']) && isset($_POST['code']) && !empty($_POST['password']) && isset($_POST['password'])
							&& !empty($_POST['passwordConfirm']) && isset($_POST['passwordConfirm']))
{
	if($_POST['passwordConfirm'] == $_POST['password'])
	{
		$password = $code=mysqli_real_escape_string($connection,$_POST['password']);
		if(strlen($_POST['password'])<6)
		{
			$msg = "<div class='alert alert-danger'>Password must be at least 6 characters.</div>";
		
		
		}
		else
		{
		  	$link =  @mysqli_connect(DB_SERVER,DB_USERNAME,DB_PASSWORD) or die(mysqli_error($link));
			mysqli_select_db($link, DB_DATABASE);
			
			$code=mysqli_real_escape_string($link,$_GET['code']);
			$c=mysqli_query($connection,"SELECT IdUser FROM login WHERE activation='$code'");
			
			if(mysqli_num_rows($c) > 0)
			{
				$password = encrypt($password);
				mysqli_query($connection,"UPDATE login SET pass='$password', activation='' WHERE activation='$code'");
				$msg="<div class='alert alert-success'>Password have been reset.</div>"; 
				echo '<div class="container-fluid col-xs-12 col-sm-6 col-md-4 panel panel-default">
					  <div class="panel-heading text-center">Reset password</div>
					  <div class="panel-body"><span class="msg">'.$msg.'</span>
					  </div>
					  </div>';
				return;
			
			}
			else
			{
			$msg ="<div class='alert alert-danger'>There was an error</div>";
			}
		}
	}
	else
	{
		$msg ="<div class='alert alert-danger'>Passwords does not match</div>";
	
	}
	
}
//HTML Part

?>
<?php// echo $msg; ?>


<body>

<div  id="main" class="center-block">
<!--<h4>Reset password</h4>-->

<form action="" method="post">
<div class="form-group container-fluid col-xs-12 col-sm-6 col-md-4 panel panel-default">
  <div class="panel-heading text-center">Reset password</div>
  <div class="panel-body">
  <span class='msg'><?php echo $msg; ?></span>
    <input type="hidden" name="code" value="<?php echo $_GET['code']; ?>"/>
	<p><input type="password" class="form-control" autofocus name="password" autocomplete="off" placeholder="Password"/></p>
	<p><input type="password" class="form-control" name="passwordConfirm"  autocomplete="off" placeholder="Re-enter password"/></p>
	<input type="submit" class="center-block btn btn-default" value="Submit" />  
  </div>
</div>
<!--<label>Email</label> <input type="text" name="email" class="input" autocomplete="off"/>-->

</form>	
</div>



</body>
</html>