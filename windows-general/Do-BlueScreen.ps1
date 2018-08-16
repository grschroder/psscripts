#Author: https://github.com/grschroder
#Description: This script will cause BSOD on your server. Execute as administrator.

$process = Get-process
foreach ($proc in $process){ Stop-Process $proc -Force }