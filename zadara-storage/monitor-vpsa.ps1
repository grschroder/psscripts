function Monitor-VPSA {    
    param (        
        $token,        
        $uri,
        $influxServer       
    )

    <#
        .Description 
        Function that monitor VPSA Engines and export data to influxDB


        .PARAMETER token
        User token that has access on VPSA.

        .PARAMETER uri
        Address of VPSA Engine.

        .PARAMETER influxServer
        InlufxDB Server

    #>

    $ErrorActionPreference = "Stop"

    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
        
    try {

        Import-Module Influx

        #$token = "XXX"
        #$uri = "XXX"
        #$influxServer = "xxx"
    
        $headers = @{              
                      "Content-Type"="application/json"
                      "X-Access-Key"="$token"
                    }
        
        
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

        if([System.Net.ServicePointManager]::CertificatePolicy -notlike "TrustAllCertsPolicy"){
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        }
        
        
        $pool = @()
        $pools = @()
        $controllers = @()
        $volumes = @()
        
        $pools = Invoke-RestMethod -Method GET -uri "$uri/pools" -Headers $headers
        $poolsCount = $pools.'show-pools-response'.'pools-count'.'#text'
        
        $controllers =  Invoke-RestMethod -Method GET -uri "$uri/vcontrollers" -Headers $headers
        $vpsaName = $controllers.'show-vcontrollers-response'.vcontrollers.vcontroller[0].'vpsa-chap-user'

        $volumes = Invoke-RestMethod -Method GET -uri "$uri/volumes" -Headers $headers        
        $volumesCount = $volumes.'show-volumes-response'.'volumes-count'.'#text'


        #Pools FreeGB and IOPS
        
        $totalwrIOPS=0
        $totalrdIOPS=0
        $avgwrIOPS=0
        $avgrdIOPS=0

        for ($i=0 ; $i -lt $poolsCount ; $i++){

            if($poolsCount -like "1"){            
                $pool = $pools.'show-pools-response'.pools.pool            
                $poolName = $pool.'display-name'
                $freeGB = $pool.'available-capacity'.'#text'
                $freeGB = [System.Convert]::ToDouble("$freeGB",[cultureinfo]::GetCultureInfo('en-US'))
                $freeGB = [math]::Round($freeGB,2)
        
                

                # Getting performance data             
                $poolName = $pool.name
                
                $perfPools = Invoke-RestMethod -Method GET -uri "$uri/pools/$poolName/performance?interval=1" -Headers $headers
                
                #de um em um minuto, um perf por segundo
                #$perfPools.'get_perf-response'.usages.usage[0].'rd-iops'.'#text'
                $perfPoolsCount = $perfPools.'get_perf-response'.'usages-count'.'#text'

                for ($perfi=0 ; $perfi -lt $perfPoolsCount ; $perfi++){                
                    $rdIOPS = $perfPools.'get_perf-response'.usages.usage[$perfi].'rd-iops'.'#text'
                    $wrIOPS = $perfPools.'get_perf-response'.usages.usage[$perfi].'wrt-iops'.'#text'
                    
                    #Normalizing output
                    $rdIOPS  = [System.Convert]::ToDouble("$rdIOPS ",[cultureinfo]::GetCultureInfo('en-US'))
                    $rdIOPS  = [math]::Round($rdIOPS,0)
                    $wrIOPS  = [System.Convert]::ToDouble("$wrIOPS ",[cultureinfo]::GetCultureInfo('en-US'))
                    $wrIOPS  = [math]::Round($wrIOPS,0)
                    
                    $totalwrIOPS = $wrIOPS + $totalwrIOPS
                    $totalrdIOPS = $rdIOPS + $totalrdIOPS
                        
                }
                    $avgwrIOPS = $totalwrIOPS/$perfPoolsCount
                    $avgrdIOPS = $totalrdIOPS/$perfPoolsCount
                    $avgwrIOPS = [math]::Round($avgwrIOPS,0)
                    $avgrdIOPS = [math]::Round($avgrdIOPS,0)
                    
            }
            else{

                $pool = $pools.'show-pools-response'.pools[$i].pool
                $poolName = $pool.'display-name'
                $freeGB = $pool.'available-capacity'.'#text'
                $freeGB = [System.Convert]::ToDouble("$freeGB",[cultureinfo]::GetCultureInfo('en-US'))
                $freeGB = [math]::Round($freeGB,2)
        
                # Getting performance data             
                $poolName = $pool.name
                
                $perfPools = Invoke-RestMethod -Method GET -uri "$uri/pools/$poolName/performance?interval=1" -Headers $headers
                
                #de um em um minuto, um perf por segundo
                #$perfPools.'get_perf-response'.usages.usage[0].'rd-iops'.'#text'
                $perfPoolsCount = $perfPools.'get_perf-response'.'usages-count'.'#text'

                for ($perfi=0 ; $perfi -lt $perfPoolsCount ; $perfi++){                
                    $rdIOPS = $perfPools.'get_perf-response'.usages.usage[$perfi].'rd-iops'.'#text'
                    $wrIOPS = $perfPools.'get_perf-response'.usages.usage[$perfi].'wrt-iops'.'#text'
                    
                    #Normalizing output
                    $rdIOPS  = [System.Convert]::ToDouble("$rdIOPS ",[cultureinfo]::GetCultureInfo('en-US'))
                    $rdIOPS  = [math]::Round($rdIOPS,0)
                    $wrIOPS  = [System.Convert]::ToDouble("$wrIOPS ",[cultureinfo]::GetCultureInfo('en-US'))
                    $wrIOPS  = [math]::Round($wrIOPS,0)
                    
                    $totalwrIOPS = $wrIOPS + $totalwrIOPS
                    $totalrdIOPS = $rdIOPS + $totalrdIOPS
                        
                }
                    $avgwrIOPS = $totalwrIOPS/$perfPoolsCount
                    $avgrdIOPS = $totalrdIOPS/$perfPoolsCount
                    $avgwrIOPS = [math]::Round($avgwrIOPS,0)
                    $avgrdIOPS = [math]::Round($avgrdIOPS,0)
                
            }

            #$vpsaName
            #$poolName            
            #$freeGB
            Write-Influx -Measure vpsa_usage -Tags @{StorageName=$vpsaName;PoolName=$poolName} -Metrics @{FreeGB=$freeGB} -Database zadara_devices -Server $influxServer
            
            #$vpsaName
            #$avgrdIOPS
            #$avgwrIOPS            
            Write-Influx -Measure vpsa_usage -Tags @{StorageName=$vpsaName;PoolName=$poolName} -Metrics @{WriteIOPS=$avgwrIOPS;ReadIOPS=$avgrdIOPS} -Database zadara_devices -Server $influxServer

        }        
        #End of Pools FreeGB and IOPS
        
        #Volumes IOPS
        $totalVolRdIOPS = 0
        $totalVolWrIOPS = 0
        for ($i=0 ; $i -lt $volumesCount ; $i++){
        
            if($volumesCount -like "1"){                
                $volumeName = $volumes.'show-volumes-response'.volumes.volume.name
                $volumeDisplayName = $volumes.'show-volumes-response'.volumes.volume.'display-name'
                

                $volumesPerf = Invoke-RestMethod -Method GET -uri "$uri/volumes/$volumeName/performance" -Headers $headers
                $volumesPerfCount = $volumesPerf.'get_volume_perf-response'.'usages-count'.'#text'
                            
                for($perfid=0 ; $perfid -lt $volumesPerfCount ; $perfid++){
                    $volumePerf = $volumesPerf.'get_volume_perf-response'.usages.usage[$perfid]
                    $volRdIOPS = $volumePerf.'rd-iops'.'#text'
                    $volWrIOPS = $volumePerf.'wrt-iops'.'#text'

                    #Normalizing output
                    $volRdIOPS  = [System.Convert]::ToDouble("$volRdIOPS ",[cultureinfo]::GetCultureInfo('en-US'))
                    $volRdIOPS  = [math]::Round($volRdIOPS,0)
                    $volWrIOPS  = [System.Convert]::ToDouble("$volWrIOPS ",[cultureinfo]::GetCultureInfo('en-US'))
                    $volWrIOPS  = [math]::Round($volWrIOPS,0)

                    $totalVolWrIOPS = $volWrIOPS + $totalVolWrIOPS
                    $totalVolRdIOPS = $volRdIOPS + $totalVolRdIOPS

                }
            }
            else{
                $volumeName = $volumes.'show-volumes-response'.volumes.volume[$i].name
                $volumeDisplayName = $volumes.'show-volumes-response'.volumes.volume[$i].'display-name'
                

                $volumesPerf = Invoke-RestMethod -Method GET -uri "$uri/volumes/$volumeName/performance" -Headers $headers
                $volumesPerfCount = $volumesPerf.'get_volume_perf-response'.'usages-count'.'#text'
                            
                for($perfid=0 ; $perfid -lt $volumesPerfCount ; $perfid++){
                    $volumePerf = $volumesPerf.'get_volume_perf-response'.usages.usage[$perfid]
                    $volRdIOPS = $volumePerf.'rd-iops'.'#text'
                    $volWrIOPS = $volumePerf.'wrt-iops'.'#text'

                    #Normalizing output
                    $volRdIOPS  = [System.Convert]::ToDouble("$volRdIOPS ",[cultureinfo]::GetCultureInfo('en-US'))
                    $volRdIOPS  = [math]::Round($volRdIOPS,0)
                    $volWrIOPS  = [System.Convert]::ToDouble("$volWrIOPS ",[cultureinfo]::GetCultureInfo('en-US'))
                    $volWrIOPS  = [math]::Round($volWrIOPS,0)

                    $totalVolWrIOPS = $volWrIOPS + $totalVolWrIOPS
                    $totalVolRdIOPS = $volRdIOPS + $totalVolRdIOPS

                }
            
            }

            $avgVolWrIOPS = $totalVolWrIOPS/$volumesPerfCount
            $avgVolRdIOPS = $totalVolRdIOPS/$volumesPerfCount
            $avgVolWrIOPS = [math]::Round($avgVolWrIOPS,0)
            $avgVolRdIOPS = [math]::Round($avgVolRdIOPS,0)

            #$volumeDisplayName
            #$avgVolWrIOPS
            #$avgVolRdIOPS
            Write-Influx -Measure vpsa_usage -Tags @{StorageName=$vpsaName;VolumeName=$volumeDisplayName} -Metrics @{VolWriteIOPS=$avgVolWrIOPS;VolReadIOPS=$avgVolRdIOPS} -Database zadara_devices -Server $influxServer        

            $avgVolWrIOPS=0
            $avgVolRdIOPS=0
            $totalVolWrIOPS=0
            $totalVolRdIOPS=0

        }
        # End of Volumes IOPS

        
        # VPSA CPU Usage
        $controllersCount = $controllers.'show-vcontrollers-response'.'vcontrollers-count'.'#text'
        $totalCPUUser=0
        $avgCPUUser=0
        $totalCPUSystem=0
        $avgCPUSystem=0
        $totalIOWait=0
        $avgIOWait=0
        for ($i=0 ; $i -lt $controllersCount ; $i++){
            $controllerName = $controllers.'show-vcontrollers-response'.vcontrollers.vcontroller[$i].name
            $controllerState = $controllers.'show-vcontrollers-response'.vcontrollers.vcontroller[$i].state

            if($controllerState -like "active"){

                $controllerPerf = Invoke-RestMethod -Method GET -uri "$uri/vcontrollers/$controllerName/performance" -Headers $headers
                $controllerPerfCount = $controllerPerf.'get_vcontroller_perf-response'.'usages-count'.'#text'

                for($perfid=0 ; $perfid -lt $controllerPerfCount; $perfid++){
                    $cpuUser = $controllerPerf.'get_vcontroller_perf-response'.usages.usage[$perfid].'cpu-user'.'#text'
                    $cpuSystem = $controllerPerf.'get_vcontroller_perf-response'.usages.usage[$perfid].'cpu-system'.'#text'
                    $ioWait = $controllerPerf.'get_vcontroller_perf-response'.usages.usage[$perfid].'cpu-iowait'.'#text'

                    #Normalizing output
                    $cpuUser  = [System.Convert]::ToDouble("$cpuUser ",[cultureinfo]::GetCultureInfo('en-US'))
                    $cpuUser  = [math]::Round($cpuUser,0)
                    $cpuSystem  = [System.Convert]::ToDouble("$cpuSystem ",[cultureinfo]::GetCultureInfo('en-US'))
                    $cpuSystem  = [math]::Round($cpuSystem,0)
                    $ioWait  = [System.Convert]::ToDouble("$ioWait ",[cultureinfo]::GetCultureInfo('en-US'))
                    $ioWait  = [math]::Round($ioWait,0)

                    $totalCPUUser = $cpuUser + $totalCPUUser
                    $totalCPUSystem = $cpuSystem + $totalCPUSystem
                    $totalIOWait = $ioWait + $totalIOWait                    
                }

                $avgCPUUser = $totalCPUUser/$controllerPerfCount
                $avgCPUUser = [math]::Round($avgCPUUser,0)
                $avgCPUSystem = $totalCPUSystem/$controllerPerfCount
                $avgCPUSystem = [math]::Round($avgCPUSystem,0)
                $avgIOWait = $totalIOWait/$controllerPerfCount
                $avgIOWait = [math]::Round($avgIOWait,0)

                #$vpsaName
                #$avgCPUUser
                #$avgCPUSystem
                #$avgIOWait
                Write-Influx -Measure vpsa_usage -Tags @{StorageName=$vpsaName} -Metrics @{CPUuser=$avgCPUUser;CPUSystem=$avgCPUSystem;IOWait=$avgIOWait} -Database zadara_devices -Server $influxServer

            }
        }
        # End of VPSA CPU Usage
    }
    catch {
        throw $_.Exception
    }
}
