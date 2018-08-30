#Author: https://github.com/grschroder
#Description: This script shows the file size of each checkpoint that you have in a cluster. Run from a cluster node.
#Tested on: Win 2012 R2


$csvs =  Get-ChildItem -Path "C:\ClusterStorage\"
$csvs = $csvs.Name
$diresName = @()
$diresSize = @()

foreach($csv in $csvs){
    $pastas =  Get-ChildItem -Path "C:\ClusterStorage\$csv"
    $pastas = $pastas.name
    $ErrorActionPreference = "SilentlyContinue"
   
    foreach($pasta in $pastas){
        $dirs = Get-ChildItem -Path "C:\ClusterStorage\$csv\$pasta\" -Filter *.avhdx
        foreach($dir in $dirs){
            $diresName += $dir.Name
            $diresSize += $dir.Length    
        }
        $dirs = Get-ChildItem -Path "C:\ClusterStorage\$csv\$pasta\Virtual Hard Disks" -Filter *.avhdx
        foreach($dir in $dirs){
            $diresName += $dir.Name
            $diresSize += $dir.Length
        }
    }
}
$i=0;
$totalSize=0
while ($i -lt $diresName.count){
    write-host $diresName[$i]";"$diresSize[$i]
    if ($i -eq 0){
        $totalSize = $diresSize[$i]
    }
    $totalSize = $totalSize + $diresSize[$i]
    $i++
}

$totalSize = $totalSize/1024/1024/1024
write-host "Tamanho total = $totalSize GB"  -ForegroundColor Cyan
