#Author: https://github.com/grschroder
#Description: This script will list the VM IPs.
#Tested on: VMM 2012 R2

Import-Module virtualmachinemanager
get-vm | select -ExpandProperty virtualnetworkadapters | select name, macaddress, IPv4Addresses