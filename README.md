# Xavyx
Social Network for iOS in Objective-C. Backend in PHP.

https://itunes.apple.com/us/app/xavyx/id935916106?ls=1&mt=8

![Week selector](https://raw.githubusercontent.com/cxca/Xavyx/master/AppImg.png)

Instructions

Objective-C
========
API.h
- Change yourdomain.com

Xavyx/Supporting Files/Xavyx-Prefic.pch
- Change globalKey (Used for encription same key is needed in PHP)

In .plist insert your Facebook app id
- FacebookAppID <FacebookAppID>
- URL types ->  URL Shemes -> <FacebookAppID>


PHP
========
1- Drop xavyx folder in your server root directory

2- Set your parameters in:
	db.php
	emailParams.php
	
3- Change the key in:
	Encryptor.php (Same key is needed in Objective-C globalKey)
	
  //Depending on your privileges to create databases, you may need to create a database manually before step 5	
4- Run install.php (Run on your web browser eg. http://yourdomain.com/xavyx/install.php) or the sql file
