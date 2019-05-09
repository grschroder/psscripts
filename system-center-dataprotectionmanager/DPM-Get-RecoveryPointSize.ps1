#Author: https://github.com/grschroder
#Description: This script gets recovery point used space and recovery point reserved space
#Tested on: DPM 2012 R2, 2012 SP1


import-module dataprotectionmanager
$dpmserver = hostname

$gps = get-protectiongroup

write-host "Name;RecoverypointSize;RecoveryReservedSize"
foreach ($gp in $gps){
   $members = Get-Datasource -ProtectionGroup $gp
      foreach ($member in $members){
         $MPG = Get-ModifiableProtectionGroup $gp
         $ds = Get-DPMDatasource $MPG | where {$_.Computer -eq $member.computer -and $_.ReplicaSize -notlike "-1"}
         #$ds.ObjectType
         #Filtrando os tipos de Datasource
         if($ds.ObjectType -like "Microsoft Hyper-V"){
            #$Shrinklimits = Get-DatasourceDiskAllocation -DataSource $ds -CalculateShrinkThresholds -ErrorAction SilentlyContinue
            #$ds.Name
            #$ds.DiskAllocation
            #$ds.ReplicaSize/1024/1024/1024
            $rpreservedsize = $ds.ShadowCopyAreaSize/1024/1024/1024
            $rpsize = $ds.ShadowCopyUsedSpace/1024/1024/1024            
            write-host $ds.Name";"$rpsize";"$rpreservedsize
         }
      }
}