## ActiveDR Demo script to end the Drill on fbperf[01|02] 
## DR workload from fbperf[01|02] will be rolled back and queued data from acrac[01|02] will be applied
## DR Array is RedDotC, Production Array is RedDotX
## Author : Danny Higgins
## Date : 10/05/2023
## Pre-Reqs : Run as the oracle user and switch to the ACTDRDBS1 environment (using the po alias is easiest)
## Notes: To make this passwordless add the oracle user public ssk key to the array using the commands below
##              (on host)    - ssh-keygen -t rsa
##              (on array)   - pureadmin setattr --publickey

DR_ARRAY=<IP_OF_DR_ARRAY>
DR_USER=pureuser
DR_POD=Oracle-DR
DR_DBNAME=ACTDRDBS
ORACLE_SID=ACTDRDBS1
ORACLE_HOME=/u01/app/oracle/product/db/12.2.0
PATH=$ORACLE_HOME/bin:$PATH

# Stop the Database
echo "About to stop the DR Database"
echo "srvctl stop database -d ${DR_DBNAME} -o immediate"
echo "Press return to contine..."
read me
srvctl stop database -d ${DR_DBNAME} -o immediate

# Dismount ASM Disk Groups (as the grid user)
echo
echo "About to dismount ASM disk groups +ADR_CONTROL_REDO +ADR_DATA +ADR_FRA"
echo "Press return to contine..."
read me
sudo su - grid -c 'echo "alter diskgroup ADR_CONTROL_REDO dismount force;" | sqlplus -s / as sysasm'
sudo su - grid -c 'echo "alter diskgroup ADR_DATA dismount force;" | sqlplus -s / as sysasm'
sudo su - grid -c 'echo "alter diskgroup ADR_FRA dismount force;" | sqlplus -s / as sysasm'

# SSH to DR array to demote the DR Pod
echo "About to demote the DR Pod (read only)"
echo "NOTE: This rolls back the changes made during the DR drill"
echo "      and apples the queued replicated writes from production"
echo "purepod demote ${DR_POD}"
echo "Press return to contine..."
read me
ssh ${DR_USER}@${DR_ARRAY} "purepod demote ${DR_POD}"
sleep 3
ssh ${DR_USER}@${DR_ARRAY} "purepod list ${DR_POD}"
