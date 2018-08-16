#Author: https://github.com/grschroder
#Description: This script will collect the physical resources from a failover cluster.
#Tested on: Win 2012 R2

#Change the name below to the target cluster: e.g.: "cluster01","cluster02"
$Clouds = "cluster01"
############################################
Import-Module FailoverClusters

$objs = @()
$obj = @()
$objCluster = @()
$objClusters = @()
$totalClusterMemory = 0
$totalClusterUsedMemory = 0
$totalClusterAvailableMemory = 0
$avgUsedClusterCPUPercentage = 0

foreach($Cloud in $Clouds){
    $totalClusterMemory = 0
    $totalClusterUsedMemory = 0
    $totalClusterAvailableMemory = 0
    $avgUsedClusterCPUPercentage = 0
	$Nodes = Get-ClusterNode -Cluster $Cloud # | ?{$_.state -like "up"}
	foreach($Node in $Nodes){
        $Sistema =  Get-WmiObject -Class Win32_OperatingSystem -Namespace root/cimv2 -ComputerName $Node
        $cores = 0
        $cores = Get-WmiObject -Class Win32_Processor -Namespace root/cimv2 -ComputerName $Node
        $cores = $cores.NumberOfCores
        $cores = $cores[0] + $cores[1]
        $procCounter = Get-Counter -Counter "\Hyper-V Hypervisor Logical Processor(_Total)\% Guest Run Time" -ComputerName $Node
        $procCounter  = $procCounter.CounterSamples.CookedValue
        $obj = New-Object PSObject -Property @{
            Name = $Node.Name
            FreeMemory = [System.Math]::Round(($Sistema).FreePhysicalMemory/(1024 * 1024), 2)
            TotalMemory = [System.Math]::Round(($Sistema).TotalVisibleMemorySize/(1024 * 1024), 2)
            UsedMemory = [System.Math]::Round(($Sistema).TotalVisibleMemorySize/(1024 * 1024), 2) - [System.Math]::Round(($Sistema).FreePhysicalMemory/(1024 * 1024), 2)
            UsedCPUPercentage = $procCounter
            NumberOfCores = $cores
            Cluster = $cloud 
        }        
        $objs += $obj
	}
    $objs | ft name, cluster, freememory, usedmemory, totalmemory, usedcpupercentage, NumberOfCores
    $formatString1 = $objs | fl name, cluster, freememory, usedmemory, totalmemory, usedcpupercentage
    foreach ($obj in $objs){
        if($i=0){
            $totalClusterMemory = $obj.TotalMemory
            $totalClusterUsedMemory = $obj.UsedMemory
            $avgUsedClusterCPUPercentage = $obj.UsedCPUPercentage            
            $i++
        }
        else {
            $totalClusterMemory = $obj.TotalMemory+$totalClusterMemory
            $totalClusterUsedMemory = $obj.UsedMemory+$totalClusterUsedMemory 
            $avgUsedClusterCPUPercentage = $obj.UsedCPUPercentage+$avgUsedClusterCPUPercentage            
        }
    }
    $i = 0
    $totalClusterUsedDisk = 0
    $csvs = Get-ClusterSharedVolume -Cluster $Cloud
    foreach($csv in $csvs){
        $csv = $csv | select -Property Name -ExpandProperty SharedVolumeInfo
        if($i -eq 0){
            $totalClusterUsedDisk = $csv.Partition.UsedSpace
            $i++
        }
        else {
            $totalClusterUsedDisk = $csv.Partition.UsedSpace+$totalClusterUsedDisk 
        }    
    }
    $totalClusterUsedDisk = $totalClusterUsedDisk/1TB
    $totalClusterUsedDisk = "{0:N2}" -f $totalClusterUsedDisk
    $avgUsedClusterCPUPercentage = $avgUsedClusterCPUPercentage/$objs.Count    
    $avgUsedClusterCPUPercentage  = "{0:N2}" -f $avgUsedClusterCPUPercentage
    $objCluster = $obj = New-Object PSObject -Property @{
        Name = $cloud
        TotalClusterMemory = $totalClusterMemory
        TotalUsedClusterMemory = $totalClusterUsedMemory
        TotalClusterAvailableMemory = $totalClusterMemory - $totalClusterUsedMemory - $obj.TotalMemory - 6 * $objs.Count
        AvgUsedClusterCPUPercentage = $avgUsedClusterCPUPercentage
        TotalClusterUsedDisk = $totalClusterUsedDisk
    }
    $objClusters += $objCluster
    $objs = @()
    $obj = @()
}

$formatString = $objClusters | ft name, TotalClusterMemory, TotalUsedClusterMemory, totalClusterAvailableMemory, avgUsedClusterCPUPercentage, TotalClusterUsedDisk
$formatString