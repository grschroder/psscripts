#Author: Guilherme Schroder
#Link: https://github.com/grschroder
#Description: Script que altera a Letra correspondendo a um volume de disco e sua Label.
#Last Modified: 01/10/2018
#Last Modified by: Leonardo Souza - https://github.com/grschroder

$ErrorActionPreference = "Stop"
$driveold = READ-HOST "Informe a letra, com os dois pontos, do disco que será alterado"
$drivenew = READ-HOST "Informe a nova letra, com dois pontos, do disco que será alterado"
$label = READ-HOST "Informe o Label para o novo disco"

$drive = Get-WmiObject -Class win32_volume -Filter "DriveLetter = '$driveold'"
Set-WmiInstance -input $drive -Arguments @{DriveLetter="$drivenew"; Label="$label"}
