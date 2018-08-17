#Author: https://github.com/grschroder
#Description: This script will count the vms quantity in each cluster node.
#Tested on: VMM 2012 R2

$hosts = Get-VMHost

foreach ($hosti in $hosts){
    $servers = get-vm | ?{$_.status -like "Running" -and $_.vmhost -like "$hosti"}
    $hosti.name 
    $servers.count

}