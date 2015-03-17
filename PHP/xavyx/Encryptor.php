<?php


	function encrypt($decrypted)
	{
	//global  $thePassKey;
	$thePassKey = "2AAE5199ECDB24F8B21F8FE395AC6";//Same key on iOS App (use your own key - for security reasons)
		# Add PKCS7 padding.
		$str = $decrypted;
		$block = mcrypt_get_block_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
		if (($pad = $block - (strlen($str) % $block)) < $block) 
		{
			$str .= str_repeat(chr($pad), $pad);
		}
	
		$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
		$iv = ''; for($i=0;$i<$iv_size;$i++){ $iv .= "\0";}
		return base64_encode(mcrypt_encrypt(MCRYPT_RIJNDAEL_128, $thePassKey, $str, MCRYPT_MODE_CBC, $iv));
	}
	
	function decrypt($encrypted)
	{
	//global  $thePassKey;
	$thePassKey = "2AAE5199ECDB24F8B21F8FE395AC6";//Same key on iOS App (use your own key - for security reasons)
		$iv_size = mcrypt_get_iv_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
		$iv = ''; for($i=0;$i<$iv_size;$i++){ $iv .= "\0";}
		$str = mcrypt_decrypt(MCRYPT_RIJNDAEL_128, $thePassKey, base64_decode($encrypted), MCRYPT_MODE_CBC, $iv);
	
		# Strip PKCS7 padding.
		$block = mcrypt_get_block_size(MCRYPT_RIJNDAEL_128, MCRYPT_MODE_CBC);
		$pad = ord($str[($len = strlen($str)) - 1]);
		if ($pad && $pad < $block && preg_match(
			'/' . chr($pad) . '{' . $pad . '}$/', $str))
		{
			return substr($str, 0, strlen($str) - $pad);
		}
		  return $str;
	}
	
?>