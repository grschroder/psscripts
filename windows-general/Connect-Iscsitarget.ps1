#Author: https://github.com/grschroder
#Description: This script will connect the iscsi targets on disconnected targets.


Update-IscsiTarget
$disks = Get-IscsiTarget | ?{$_.isconnected -like "false"}
$disks.NodeAddress
foreach ($disk in $disks){
	Connect-IscsiTarget -NodeAddress $disk.NodeAddress -IsPersistent $true -IsMultipathEnabled $true
}
