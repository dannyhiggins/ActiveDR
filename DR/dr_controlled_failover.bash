## ActiveDR Demo script to start a controlled DR failover from acrac[01|02] to fbperf[01|02] 
## Production workload will be stopped on acrac[01|02] the Oracle-PROD Pod will be demoted and
## the Oracle-DR Pod will be promoted so the workload can continue at the DR Site
## DR Array is RedDotC, Production Array is RedDotX
## Author : Danny Higgins
## Date : 10/05/2023
## Pre-Reqs : Run as the oracle user and switch to the ACTDRDBS1 environment (using the po alias is easiest)
## Notes: To make this passwordless add the oracle user public ssk key to the array using the commands below
##              (on host)    - ssh-keygen -t rsa
##              (on array)   - pureadmin setattr --publickey

PROD_HOST=acrac1.puresg.com
DR_ARRAY=<IP_OF_DR_ARRAY>
DR_USER=pureuser
DR_POD=Oracle-DR
DR_DBNAME=ACTDRDBS
ORACLE_SID=ACTDRDBS1
ORACLE_HOME=/u01/app/oracle/product/db/12.2.0
PATH=$ORACLE_HOME/bin:$PATH

# Stop the PROD Database, ASM Disk Groups & Demote POD
echo "About to stop the PROD Database, ASM Disk Groups & Demote POD"
echo "Running script /home/oracle/actdr_demo/dr_controlled_failover.bash on PROD host ${PROD_HOST}"
echo "Press return to contine..."
read me
ssh oracle@${PROD_HOST} '/home/oracle/actdr_demo/dr_controlled_failover.bash'

# SSH to DR array to promote the DR Pod
echo "About to promote the DR Pod (read/write) to allow DR ASM Disk Groups to be MOUNTED"
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
echo "This will now be the master as the PROD Pod is demoted" 
echo "All writes will replicated in reverse direction to PROD"
echo "srvctl start database -d ${DR_DBNAME}"
echo "Press return to contine..."
read me
srvctl start database -d ${DR_DBNAME}

