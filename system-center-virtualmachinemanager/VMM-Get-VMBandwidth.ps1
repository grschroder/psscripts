#Author: https://github.com/grschroder
#Description: This script will check the bandwidth limit of all vms.
#Tested on: VMM 2012 R2

Import-Module virtualmachinemanager
#Change the name of vmm server here
$vmms = "VMMSERVER01"
####################################
$vms = @()
$vmhosts = @()

# hyper-v
#NetworkAdapters.BandwidthSetting.maximumbandwidth
foreach($vmm in $vmms){
    $vms += Get-SCVirtualMachine -VMMServer $vmm
    $vmhosts += Get-SCVMHost -VMMServer $vmm
}

Write-Host "NomeVM;BandwidthLimit"
foreach($vmhost in $vmhosts){
    $s = New-PSSession -ComputerName $vmhost.Name
    foreach($vm in $vms){
        if($vm.VMHost.name -like $vmhost.Name){
            Invoke-Command -Session $s -ScriptBlock {
                param($name)
                $vmSettings = Get-VM $name
                $bandwidth = $vmSettings.NetworkAdapters.BandwidthSetting.maximumbandwidth/1000000
                write-host "$name;$bandwidth" -ForegroundColor Green
                #break
            } -ArgumentList $vm.Name
        }
    }
    #break
    Remove-PSSession $s
}