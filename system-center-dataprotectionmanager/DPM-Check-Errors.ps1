#Author: https://github.com/grschroder
#Description: This script check the quantity of error on dpm server.
#Tested on: DPM 2012 R2, 2012 SP1


$qtd = 0
$Erros = Get-dpmalert -IncludeAlerts AllActive
foreach ($filho in $erros){
   if (($filho.severity -like "Error") ){
	   $qtd=$qtd+1;   
   }
}
write-host $qtd;
if ($qtd -gt 0){
   Write-EventLog -LogName Application -Source "DPMAlertsCritical" -EntryType "Error" -EventId 60300 -Message "description."
} else {
   Write-EventLog -LogName Application -Source "DPMAlertsOk" -EntryType "Information" -EventId 60301 -Message "description."
}