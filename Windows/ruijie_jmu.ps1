#If received logout parameter, send a logout request to eportal server
if ($args[0] -eq "logout") {
  $userIndex = Invoke-WebRequest -Uri "http://10.8.2.2/eportal/redirectortosuccess.jsp" -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.91 Safari/537.36" -Method Head | Select-String -Pattern 'userIndex=.*' -AllMatches | ForEach-Object {$_.Matches.Value}
  $logoutResult = Invoke-WebRequest -Uri "http://10.8.2.2/eportal/InterFace.do?method=logout" -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.91 Safari/537.36" -Method Post -Body $userIndex
  Write-Output $logoutResult
  exit 0
}

#If received parameters is less than 3, print usage
if ($args.Count -lt 3) {
  Write-Output "Usage: .\ruijie_jmu.ps1 interface username password"
  Write-Output "interface can be \"campus\", \"chinamobile\", \"chinanet\" and \"chinaunicom\"."
  Write-Output "Example: .\ruijie_jmu.ps1 chinanet 201620000000 123456"
  Write-Output "if you want to logout, use: .\ruijie_jmu.ps1 logout"
  exit 1
}

#Exit the script when is already online, use connect.rom.miui.com/generate_204 to check the online status
$captiveReturnCode = Invoke-WebRequest -Uri "http://connect.rom.miui.com/generate_204" -Method Head | Select-Object -ExpandProperty StatusCode
if ($captiveReturnCode -eq 204) {
  Write-Output "You are already online!"
  exit 0
}

#If not online, begin Ruijie Auth

#Get Ruijie login page URL
$loginPageURL = Invoke-WebRequest -Uri "http://10.8.2.2" | Select-String -Pattern "'.*'" -AllMatches | ForEach-Object {$_.Matches.Value.Trim("'")}

$chinamobile="%25E7%25A7%25BB%25E5%258A%25A8%25E5%25AE%25BD%25E5%25B8%25A6%25E6%258E%25A5%25E5%2585%25A5"
$chinanet="%25E7%2594%25B5%25E4%25BF%25A1%25E5%25AE%25BD%25E5%25B8%25A6%25E6%258E%25A5%25E5%2585%25A5"
$chinaunicom="%25E8%2581%2594%25E9%2580%259A%25E5%25AE%25BD%25E5%25B8%25A6%25E6%258E%25A5%25E5%2585%25A5"
$campus="%E6%95%99%E8%82%B2%E7%BD%91%E6%8E%A5%E5%85%A5"

$interface=""

if ($args[0] -eq "chinamobile") {
  Write-Output "Use ChinaMobile as auth interface."
  $interface = $chinamobile
}

if ($args[0] -eq "chinanet") {
  Write-Output "Use ChinaNet as auth interface."
  $interface = $chinanet
}

if ($args[0] -eq "chinaunicom") {
  Write-Output "Use ChinaUnicom as auth interface."
  $interface = $chinaunicom
}

if ($args[0] -eq "campus") {
  Write-Output "Use Campus Network as auth interface."
  $interface = $campus
}

#Structure loginURL
$loginURL = $loginPageURL -split "\?" | Select-Object -First 1
$loginURL = $loginURL.Replace("index.jsp","InterFace.do?method=login")

#Structure queryString
$queryString = $loginPageURL -split "\?" | Select-Object -Last 1
$queryString = $queryString.Replace("&","%2526")
$queryString = $queryString.Replace("=","%253D")

#Send Ruijie eportal auth request and output result
if ([string]::IsNullOrEmpty($loginURL) -eq $false) {
  $authResult = Invoke-WebRequest -Uri $loginURL -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.91 Safari/537.36" -Headers @{"Referer"=$loginPageURL; "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8"} -Method Post -Body "userId=$($args[1])&password=$($args[2])&service=$interface&queryString=$queryString&operatorPwd=&operatorUserId=&validcode=&passwordEncrypt=false" -ContentType "application/x-www-form-urlencoded; charset=UTF-8" | Select-Object -ExpandProperty Content
  Write-Output $authResult
}
