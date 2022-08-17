#Cores de cpu, preciso disso pra saber a porcentagem correta de uso
$cpu_cores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors
#Porcentagem limite
$threshold=10
#Calculo para saber a porcentagem corretamente
$threshold = (($cpu_cores*100)*$threshold)/100
#Pego os processos que estao acima da porcentagem que setei em "threshold"
$procs = (Get-Counter '\Process(*)\% Processor Time').CounterSamples | Where-Object {$_.CookedValue -gt $threshold} 
# Iterar sob cada processo encontrado
foreach($proc in $procs){
    # excluir os "processos" idle e total
    if ($proc.path -notlike "*idle*" -and $proc.path -notlike "*_total*"){
        # quero a porcentagem com relacao ao total de cpu, nao aos cores, ou seja, valores ate 100%
        $cpuUsed = $proc.CookedValue / $cpu_cores
        # printando o nome do processo
        write-host "Process Name:" $proc.instancename -ForegroundColor Cyan
        # printando a porcentagem
        $cpuUsed = [Math]::Round($cpuUsed,1)
        write-host "Used CPU: $cpuUsed%" -ForegroundColor Yellow        
    }
}