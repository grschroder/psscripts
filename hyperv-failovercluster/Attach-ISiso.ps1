#Author: https://github.com/grschroder
#Description: This script attach integration services iso in ALL of your VMs in a failover cluster. Execute from a cluster node.

$iso = Read-Host "Type the full .iso Path"
$hvs = Get-ClusterNode
foreach( $hv in $hvs ){
    Invoke-Command -ComputerName $hv -ScriptBlock { 
        $Machines = Get-VM
        Foreach ($Machine in $Machines) {            
	        write-host "Attaching iso..." $Machine.name
            Set-VMDvdDrive $Machine.name -Path $iso -AllowUnverifiedPaths         
        }
   }
}
