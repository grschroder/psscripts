#Author: https://github.com/grschroder
#Description: This script will export all smartermail users to a file.

$domains = Get-Content -Path "C:\Program Files (x86)\SmarterTools\SmarterMail\Service\domainList.xml"
foreach ($domain in $domains){    
        [xml]$xmlusers = Get-Content -Path "C:\Smartermail\Domains\$domain\accountList.xml"
        $userst = $xmlusers.AddressList.Address.name        
        foreach ($user in $userst){            
            $user+"@"+$domain >> "C:\smUsers.txt"
        }
}