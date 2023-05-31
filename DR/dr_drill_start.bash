## ActiveDR Demo script to start a Drill on fbperf[01|02] 
## Production workload will continue running on acrac[01|02]
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

# SSH to DR array to promote the DR Pod
echo "About to promote the DR Pod (read/write) to allow DR ASM Disk Groups to be MOUNTED"
echo "NOTE: This stops applying the replicated writes, they will be applied once the Pod is Demoted"
echo "purepod promote ${DR_POD}"
echo "Press return to contine..."
read me
ssh ${DR_USER}@${DR_ARRAY} "purepod promote ${DR_POD}"
sleep 3
ssh ${DR_USER}@${DR_ARRAY} "purepod list ${DR_POD}"

# Mount ASM Disk Groups (as the grid user)
echo
echo "About to mount ASM disk groups +ADR_CONTROL_REDO +ADR_DATA +ADR_FRA"
echo "Press return to contine..."
read me
sudo su - grid -c 'echo "alter diskgroup ADR_CONTROL_REDO mount force;" | sqlplus -s / as sysasm'
sudo su - grid -c 'echo "alter diskgroup ADR_DATA mount force;" | sqlplus -s / as sysasm'
sudo su - grid -c 'echo "alter diskgroup ADR_FRA mount force;" | sqlplus -s / as sysasm'

# Start the Database
echo "About to start the DR Database"
echo "srvctl start database -d ${DR_DBNAME}"
echo "Press return to contine..."
read me
srvctl start database -d ${DR_DBNAME}

