#Author: https://github.com/grschroder
#Description: This script lists vms that has hyper-v compatibility processor mode activated.
#Tested on: VMM 2012 R2

Import-Module VirtualMachineManager

$cluster = Read-Host "Type the cluster name"
$vmmServer  = Read-Host "Type the VMM server name"

$vms = Get-SCVirtualMachine -VMMServer $vmmServer | ?{$_.hostgrouppath -like "*$cluster*" -and $_.LimitCPUForMigration -like "false"}

$vms.name | Sort-Object
write-host "Quantidade de vms com modo de compatibilidade DESATIVADO: "$vms.Count -ForegroundColor Cyan
