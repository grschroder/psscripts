#Author: https://github.com/grschroder
#Description: This script enables compatibility mode in hyper-v. WARNING: It will stop all VMs to do so.
#Tested on: VMM 2012 R2

Import-Module VirtualMachineManager

$vm = @()
$vms = @()
$path = Read-Host "Type the file path that contains the list of VMs"
$vmmServer  = Read-Host "Type the name of VMM server"
$sleep = Read-Host "Type the time in seconds to wait between jobs"

$vms = Get-Content -Path $path

foreach($vm in $vms){
    Start-Job -Name $vm -ScriptBlock {      
        param($vm)  
        $vm = Get-SCVirtualMachine $vm -VMMServer $vmmServer
        write-host "Stopping VM: $vm" -ForegroundColor cyan
        Stop-SCVirtualMachine -VM $vm -Shutdown 
        write-host "Enabling compatibility mode: $vm" -ForegroundColor Green        
        Set-SCVirtualMachine -VM $vm -CPULimitForMigration $true
        write-host "Starting VM: $vm" -ForegroundColor White
        Start-SCVirtualMachine -VM $vm
    } -ArgumentList $vm
    sleep 18
}
