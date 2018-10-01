#Author: Guilherme Schroder
#Link: https://github.com/grschroder
#Description: This script attach integration services iso in ALL of your VMs in a failover cluster. Execute from a cluster node.
#Last Modified: 01/10/2018
#Last Modified by: Leonardo Souza - https://github.com/leonardomv1

$isoAddress = Read-Host "Enter the address for iso file. Example: C:\Windows\System32\vmguest.iso"

$hvs = Get-ClusterNode
foreach( $hv in $hvs ){
    Invoke-Command -ComputerName $hv -ScriptBlock { 
        $Machines = Get-VM
        Foreach ($Machine in $Machines) {            
	        write-host "Attaching iso..." $Machine.name
            Set-VMDvdDrive $Machine.name -Path "$isoAddress" -AllowUnverifiedPaths         
        }
   }
}
