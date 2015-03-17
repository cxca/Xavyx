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
    chdir("..");
//}
include './db.php';
$msg='';
if(!empty($_GET['code']) && isset($_GET['code']))
{
	$link =  @mysqli_connect(DB_SERVER,DB_USERNAME,DB_PASSWORD) or die(mysqli_error($link));
	mysqli_select_db($link, DB_DATABASE);
	
	$code=mysqli_real_escape_string($link,$_GET['code']);
	$c=mysqli_query($connection,"SELECT IdUser FROM login WHERE activation='$code'");
	
	if(mysqli_num_rows($c) > 0)
	{
		$count=mysqli_query($connection,"SELECT IdUser FROM login WHERE activation='$code' and status='0'");
	
		if(mysqli_num_rows($count) == 1)
		{
			mysqli_query($connection,"UPDATE login SET status='1' WHERE activation='$code'");
			$msg="<div class='alert alert-success container-fluid col-xs-12 col-sm-6 col-md-4 '>Your account has been activated</div>"; 
		}
		else
		{
			$msg ="<div class='alert alert-warning container-fluid col-xs-12 col-sm-6 col-md-4 '>Your account is already active, no need to activate again</div>";
		}
	
	}
	else
	{
	$msg ="<div class='alert alert-danger center-block container-fluid col-xs-12 col-sm-6 col-md-4 '>Wrong activation code.</div>";
	}

}
//HTML Part

?>
<!doctype html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>xavyx</title>
<link rel="stylesheet"  type="text/css" href="activation.css"/>
</head>
<body>
<div id="main">
<h1></h1>

<?php echo $msg; ?>
</div>

<style>
body{
font-family:Arial, Helvetica, sans-serif; 
font-size:13px;
}
.info, .success, .warning, .error, .validation {
border: 1px solid;
margin: 10px 0px;
padding:15px 10px 15px 50px;
background-repeat: no-repeat;
background-position: 10px center;
}
.info {
color: #00529B;
background-color: #BDE5F8;
background-image: url('icons/info.png');
}
.success {
color: #4F8A10;
background-color: #DFF2BF;
background-image:url('icons/success.png');
}
.warning {
color: #9F6000;
background-color: #FEEFB3;
background-image: url('icons/warning.png');
}
.error {
color: #D8000C;
background-color: #FFBABA;
background-image: url('icons/error.png');
}
</style>

</body>
</html>