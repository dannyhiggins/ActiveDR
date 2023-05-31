## ActiveDR Demo script to start a controlled DR failback from fbperf[01|02] to acrac[01|02]
## Production Array is RedDotX, DR Array is RedDotC
## Author : Danny Higgins
## Date : 10/05/2023
## Pre-Reqs : Run as the oracle user and switch to the ACTDRDBS1 environment (using the po alias is easiest)
## Notes: To make this passwordless add the oracle user public ssk key to the array using the commands below
##              (on host)    - ssh-keygen -t rsa
##              (on array)   - pureadmin setattr --publickey

DR_HOST=fbperf01.purestorage.int
PROD_ARRAY=<IP_OF_PROD_ARRAY>
PROD_USER=acrac1
PROD_POD=Oracle-PROD
PROD_DBNAME=ACTDRDBS
ORACLE_SID=ACTDRDBS1
ORACLE_HOME=/u01/app/oracle/product/db/12cR2 
PATH=$ORACLE_HOME/bin:$PATH

# Stop the DR Database, ASM Disk Groups & Demote POD
echo "About to stop the DR Database, ASM Disk Groups & Demote POD"
echo "Running script /home/oracle/actdr_demo/dr_controlled_failback.bash on DR host ${DR_HOST}"
echo "Press return to contine..."
read me
ssh oracle@${DR_HOST} '/home/oracle/actdr_demo/dr_controlled_failback.bash'

# SSH to PROD array to promote the PROD Pod
echo "About to prommote the PROD Pod (read/write)"
echo "purepod promote ${PROD_POD}"
echo "Press return to contine..."
read me
ssh ${PROD_USER}@${PROD_ARRAY} "purepod promote ${PROD_POD}"
sleep 3
ssh ${PROD_USER}@${PROD_ARRAY} "purepod list ${PROD_POD}"

# Mount ASM Disk Groups (as the grid user)
echo
echo "About to mount ASM disk groups +ADR_CONTROL_REDO +ADR_DATA +ADR_FRA"
echo "Press return to contine..."
read me
sudo su - grid -c 'echo "alter diskgroup ADR_CONTROL_REDO mount force;" | sqlplus -s / as sysasm'
sudo su - grid -c 'echo "alter diskgroup ADR_DATA mount force;" | sqlplus -s / as sysasm'
sudo su - grid -c 'echo "alter diskgroup ADR_FRA mount force;" | sqlplus -s / as sysasm'

# Start the Database
echo "About to start the PROD Database"
echo "srvctl start database -d ${PROD_DBNAME}"
echo "Press return to contine..."
read me
srvctl start database -d ${PROD_DBNAME}

echo
echo "POD ${PROD_POD} PROMOTED, ASM MOUNTED, PRODUCTION DATABASE ${PROD_DBNAME} STARTED" 
