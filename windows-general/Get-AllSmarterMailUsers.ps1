#Author: Guilherme Schroder
#Link: https://github.com/grschroder
#Description: This script will export all smartermail users to a file.
#Last Modified: 01/10/2018
#Last Modified by: Leonardo Souza - https://github.com/leonardomv1

$domainListAddress = READ-HOST "Enter the complete address where the domainList file is stored. Example: C:\Program Files (x86)\SmarterTools\SmarterMail\Service\domainList.xml"
$accountListAddress = READ-HOST "Enter the address where the domains is stored. Example: C:\Smartermail\Domains\"
$result = READ-HOST "Enter the complete address where the result file will be stored"
$domains = Get-Content -Path "$domainsListAdress"
foreach ($domain in $domains){    
        [xml]$xmlusers = Get-Content -Path "$accountListAddress+$domain\accountList.xml"
        $userst = $xmlusers.AddressList.Address.name        
        foreach ($user in $userst){            
            $user+"@"+$domain >> "$result"
        }
}
