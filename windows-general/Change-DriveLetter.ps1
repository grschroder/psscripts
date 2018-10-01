#Author: Guilherme Schroder
#Link: https://github.com/grschroder
#Description: Script que altera a Letra correspondendo a um volume de disco e sua Label.
#Last Modified: 01/10/2018
#Last Modified by: Leonardo Souza - https://github.com/leonardomv1

$ErrorActionPreference = "Stop"
$driveold = READ-HOST "Enter the disk Letter 'A:'"
$drivenew = READ-HOST "Enter the new dis Letter 'B:'"
$label = READ-HOST "Enter the new disk Label"

$drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$driveold'"
Set-WmiInstance -input $drive -Arguments @{DriveLetter="$drivenew"; Label="$label"}
