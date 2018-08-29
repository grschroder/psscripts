#Author: https://github.com/grschroder
#Description: This script will check a specific KB number.

Get-WmiObject Win32_PnPSignedDriver| select devicename, driverversion, driverdate