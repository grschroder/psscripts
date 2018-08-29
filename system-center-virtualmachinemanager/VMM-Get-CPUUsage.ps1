#Author: https://github.com/grschroder
#Description: This script will get relevant VMs that use CPU.
#Tested on: VMM 2012 R2

import-module virtualmachinemanager

$vms = Get-VM | ?{$_.status -like "Running" -and $_.PerfCPUUtilization -gt 10 -and $_.CPUCount -gt 5 }
$vms | Sort-Object -Property PerfCPUUtilization -Descending | ft name, PerfCPUUtilization, CPUCount, CPUMax, VMhost