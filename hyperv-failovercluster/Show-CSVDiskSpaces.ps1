#Author: https://github.com/grschroder
#Description: This script will show information about the CSV disks.
#Tested on: Win 2012 R2

$Clusters = Read-Host "Type the name of cluster"
Foreach($Cluster in $Clusters){
	Import-Module FailoverClusters
	$objs = @()
	$csvs = Get-ClusterSharedVolume -Cluster $Cluster
	foreach ( $csv in $csvs )
	{
	   $csvinfos = $csv | select -Property Name -ExpandProperty SharedVolumeInfo
	   foreach ( $csvinfo in $csvinfos )
	   {
      		$obj = New-Object PSObject -Property @{
        		Path        = $csvinfo.FriendlyVolumeName.Replace("C:\ClusterStorage\","")
        		Size        = $csvinfo.Partition.Size
        		FreeSpace   = $csvinfo.Partition.FreeSpace
        		UsedSpace   = $csvinfo.Partition.UsedSpace
        		PercentFree = $csvinfo.Partition.PercentFree
 		}
   	    $objs += $obj
	    }
	}
$Objs = $objs | ft -auto Path,@{ Label = "Free(GB)" ; Expression = { "{0:N2}" -f ($_.FreeSpace/1024/1024/1024) } } | out-string
#$Objs = $objs | ft -auto Path,@{ Label = "Used(GB)" ; Expression = { "{0:N2}" -f ($_.UsedSpace/1024/1024/1024) } } | out-string

$objs
}




