#Author: https://github.com/grschroder
#Description: Check the disk space from a volume.

$device =Read-Host "Inform the drive letter (e.g: C:)"
$disk = get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$device'"
Write-Host "Device: " $device 
Write-Host "Free space (GB): " 
$disk.FreeSpace/1024/1024/1024
Write-Host "Size (GB): " 
$disk.Size/1024/1024/1024
