#Author: https://github.com/grschroder
#Description: This script will try to reduce the space used of virtual machine and disks backups.
#Tested on: DPM 2012 R2, 2012 SP1


import-module dataprotectionmanager
$dpmserver = hostname

$gps = get-protectiongroup

foreach ($gp in $gps){
   $members = Get-Datasource -ProtectionGroup $gp
      foreach ($member in $members){
         $MPG = Get-ModifiableProtectionGroup $gp
         $ds = Get-DPMDatasource $MPG | where {$_.Computer -eq $member.computer -and $_.ReplicaSize -notlike "-1"}
         #$ds.ObjectType
         #Filtrando os tipos de Datasource
         if($ds.ObjectType -like "Microsoft Hyper-V"){
            $Shrinklimits = Get-DatasourceDiskAllocation -DataSource $ds -CalculateShrinkThresholds -ErrorAction SilentlyContinue
            $Shrinkdisk = $shrinklimits.ShadowCopySizeAfterMaxShrink         
            if ($shrinklimits.ShadowCopySizeAfterMaxShrink/1GB -notlike "0"){
               $teste = $shrinklimits.ShadowCopySizeAfterMaxShrink/1GB
               $teste2 = $Shrinklimits.ShadowCopyAreaSize/1GB
               write-host "VM:"$ds.computer "- NewShadowCopySize:"$teste "- OldShadowCopySize:"$teste2
               Set-DatasourceDiskAllocation -Manual -Datasource $ds -ProtectionGroup $MPG -ShadowCopyArea $Shrinkdisk
               write-host "Salvando o grupo"
               Set-ProtectionGroup $MPG -Confir:$false               
            }
         }
         if ($ds.ObjectType -like "Volume"){
            foreach($d in $ds){
               $Shrinklimits = Get-DatasourceDiskAllocation -DataSource $d -CalculateShrinkThresholds -ErrorAction SilentlyContinue
               $Shrinkdisk = $shrinklimits.ShadowCopySizeAfterMaxShrink         
                  if ($shrinklimits.ShadowCopySizeAfterMaxShrink/1GB -notlike "0"){
                     $teste = $shrinklimits.ShadowCopySizeAfterMaxShrink/1GB
                     $teste2 = $Shrinklimits.ShadowCopyAreaSize/1GB
                     write-host "VM:"$d.computer "Disco:"$d.name "- NewShadowCopySize:"$teste "- OldShadowCopySize:"$teste2
                     Set-DatasourceDiskAllocation -Manual -Datasource $d -ProtectionGroup $MPG -ShadowCopyArea $Shrinkdisk
                     write-host "Salvando o grupo"
                     Set-ProtectionGroup $MPG -Confir:$false 
                  }
            }
         }         
      }
}