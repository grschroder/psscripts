#Author: https://github.com/grschroder
#Description: This script will change the drive letter of a volume.

$drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = 'H:'"
Set-WmiInstance -input $drive -Arguments @{DriveLetter="L:"; Label="Logs"}