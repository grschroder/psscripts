#Author: https://github.com/grschroder
#Description: This script attach integration services iso in ALL of your VMs in a failover cluster. Execute from a cluster node.


$hvs = Get-ClusterNode
foreach( $hv in $hvs ){
    Invoke-Command -ComputerName $hv -ScriptBlock { 
        $Machines = Get-VM
        Foreach ($Machine in $Machines) {            
	        write-host "Attaching iso..." $Machine.name
            Set-VMDvdDrive $Machine.name -Path "C:\Windows\System32\vmguest.iso" -AllowUnverifiedPaths         
        }
   }
}