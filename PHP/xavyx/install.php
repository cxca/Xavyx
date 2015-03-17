<?
require_once("db.php");
	
//setup db connection
$link =  @mysqli_connect(DB_SERVER,DB_USERNAME,DB_PASSWORD) or die(mysqli_error($link));
mysqli_select_db($link, DB_DATABASE);

// Check connection
if (mysqli_connect_errno())
  {
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
  }
  
  //Depending on your privileges to create databases, you may need to create a database manually
 /* 
// Create database
$sql="CREATE DATABASE db_name";
if (mysqli_query($link,$sql))
{
  echo "Database my_db created successfully";
}
else
{
  echo "Error creating database: " . mysqli_error($link);
}  
 */ 
 echo "Creating tables:<br><br>";
  
// Create table
$sql = "CREATE TABLE deviceToken
(
id int NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
IdUser int(255),
token varchar(100),
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "deviceToken success";
}
else
{
  echo "deviceToken Error creating table: " . mysqli_error($link);
}

//
$sql = "CREATE TABLE flag
(
id int NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
IdPhoto varchar(255),
IdUser int(255),
type varchar(255),
IdUserFlag varchar(255),
flagged int(1),
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>flag success";
}
else
{
  echo "<br>flag Error creating table: " . mysqli_error($link);
}

//
$sql = "CREATE TABLE flagDeletedPhotos
(
id int NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
IdPhoto varchar(255),
IdUser int(255),
title varchar(255),
life datetime,
likes int(11),
flags int(11),
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>flagDeletedPhotos success";
}
else
{
  echo "<br>flagDeletedPhotos Error creating table: " . mysqli_error($link);
}

//
$sql = "CREATE TABLE forgotPassword
(
id int NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
ip varchar(50),
email int(255),
attempts int,
life datetime,
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>forgotPassword success";
}
else
{
  echo "<br>forgotPassword Error creating table: " . mysqli_error($link);
}

//
$sql = "CREATE TABLE likes
(
id int NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
IDPhoto varchar(255),
IdUser int(255),
IdUserLike int(255),
liked int(1),
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>likes success";
}
else
{
  echo "<br>likes Error creating table: " . mysqli_error($link);
}

//
$sql = "CREATE TABLE login
(
IDUser int(255) NOT NULL AUTO_INCREMENT,
PRIMARY KEY(IDUser),
username varchar(50),
pass varchar(255),
firstname varchar(255),
lastname varchar(255),
profileImage varchar(255),
email varchar(255),
status tinyint(1),
activation varchar(300),
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>login success";
}
else
{
  echo "<br>login Error creating table: " . mysqli_error($link);
}

//
$sql = "CREATE TABLE notifications
(
id int(255) NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
IDPhoto varchar(255),
IdUser int(255),
type varchar(20),
message text,
status enum('unread','read'),
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>notifications success";
}
else
{
  echo "<br>notifications Error creating table: " . mysqli_error($link);
}


//
$sql = "CREATE TABLE photoComments
(
id int(255) NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
IDPhoto varchar(255),
IdUser int(255),
comment varchar(500),
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>photoComments success";
}
else
{
  echo "<br>photoComments Error creating table: " . mysqli_error($link);
}

//
$sql = "CREATE TABLE photoCommentsAPNS
(
id int(255) NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
IDPhoto varchar(255),
IdUser int(255)
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>photoCommentsAPNS success";
}
else
{
  echo "<br>photoCommentsAPNS Error creating table: " . mysqli_error($link);
}

//
$sql = "CREATE TABLE photoComments
(
id int(255) NOT NULL AUTO_INCREMENT,
PRIMARY KEY(id),
IDPhoto varchar(255),
IdUser int(255),
title varchar(255),
life datetime,
likes int(11),
flags int(11),
active tinyint(1),
othersIdUser int(255),
transactionDateTime timestamp
)";

// Execute query
if (mysqli_query($link,$sql))
{
  echo "<br>photoComments success";
}
else
{
  echo "<br>photoComments Error creating table: " . mysqli_error($link);
}


mysqli_close($link);
?>
