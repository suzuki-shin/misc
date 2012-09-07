{-# OPTIONS -Wall #-}
import Network.CGI
import Data.Maybe

appId :: String
appId = "YOUR_APP_ID";
appSecret :: String
appSecret = "YOUR_APP_SECRET";
myUrl :: String
myUrl = "YOUR_URL";

cgiMain :: CGI CGIResult
cgiMain = do
  setHeader "Content-type" "text/html; charset = UTF-8"
  script <- scriptName
  name <- getInput "code"
  output $ script
--   output $ (fromJust name) ++ script

main :: IO ()
main = runCGI (handleErrors cgiMain)

{--
<?php
$app_id = "YOUR_APP_ID";
$app_secret = "YOUR_APP_SECRET";
$my_url = "YOUR_URL";

$code = $_REQUEST["code"];

if(empty ($code))
{
    $dialog_url = "https://accounts.google.com/o/oauth2/auth?"
       . "scope=https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email+https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.profile&"
       . "client_id=" . $app_id . "&redirect_uri=" . urlencode ($my_url) . "&response_type=code";

    echo("<script> top.location.href='" . $dialog_url . "'</script>");
}

$token_url = "https://accounts.google.com/o/oauth2/token";
$params = "code=" . $code;
$params .= "&client_id=" . $app_id;
$params .= "&client_secret=" . $app_secret;
$params .= "&redirect_uri=" . urlencode ($my_url);
$params .= "&grant_type=authorization_code";
$response = dorequest ($token_url, $params, 'POST');

$response = json_decode ($response);
if (isset ($response->access_token))
{
	$info_url = 'https://www.googleapis.com/oauth2/v1/userinfo';
	$params = 'access_token=' . urlencode ($response->access_token);
	unset ($response);
	$response = dorequest ($info_url, $params, 'GET');
	if (isset ($response->id))
	{
		$response = json_decode ($response);
		print_r ($response);
	}
}

function dorequest ($url, $params, $type)
{
	$ch = curl_init ();
	if ($type == 'POST')
	{
		curl_setopt ($ch, CURLOPT_URL, $url);
		curl_setopt ($ch, CURLOPT_POSTFIELDS, $params);
		curl_setopt ($ch, CURLOPT_POST, 1);
	}
	else
		curl_setopt ($ch, CURLOPT_URL, $url . "?" . $params);
	curl_setopt ($ch, CURLOPT_RETURNTRANSFER, 1);
	unset ($response);
	$response = curl_exec ($ch);
	curl_close ($ch);
	return $response;
}
?>
--}