#Author: https://github.com/grschroder
#Description: This script will export all scheduled tasks from a path.

# change the path location
Get-ScheduledTask -TaskPath "\Microsoft\"
foreach($task in $tasks){
	New-Item -Name $task.taskname -Type file -Force
	Export-ScheduledTask -TaskName $task.taskname -TaskPath $task.taskpath > $task.taskname
}