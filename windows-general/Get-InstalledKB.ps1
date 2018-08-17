#Author: https://github.com/grschroder
#Description: This script will check a specific KB number.

$outputs = Invoke-Expression "wmic qfe list" 

$kb = Read-Host "Type the KB number"

foreach($out in $outputs){
	if ($out -like "*$kb*"){ 
		$out		
    }
}