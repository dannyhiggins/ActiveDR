## ActiveDR Demo script to shutdown stack on acrac[01|02] (DB,ASMDG,POD)
## Production Array is RedDotX
## Author : Danny Higgins
## Date : 10/05/2023
## Pre-Reqs : Run as the oracle user and switch to the ACTDRDBS1 environment (using the po alias is easiest)
## Notes: To make this passwordless add the oracle user public ssk key to the array using the commands below
##              (on host)    - ssh-keygen -t rsa
##              (on array)   - pureadmin setattr --publickey

PROD_ARRAY=<IP_OF_PROD_ARRAY>
PROD_USER=acrac1
PROD_POD=Oracle-PROD
PROD_DBNAME=ACTDRDBS
ORACLE_SID=ACTDRDBS1
ORACLE_HOME=/u01/app/oracle/product/db/12cR2 
PATH=$ORACLE_HOME/bin:$PATH

# Stop the Database
echo "About to stop the PROD Database"
echo "srvctl stop database -d ${PROD_DBNAME} -o immediate"
echo "Press return to contine..."
read me
srvctl stop database -d ${PROD_DBNAME} -o immediate

# Dismount ASM Disk Groups (as the grid user)
echo
echo "About to dismount ASM disk groups +ADR_CONTROL_REDO +ADR_DATA +ADR_FRA"
echo "Press return to contine..."
read me
sudo su - grid -c 'echo "alter diskgroup ADR_CONTROL_REDO dismount force;" | sqlplus -s / as sysasm'
sudo su - grid -c 'echo "alter diskgroup ADR_DATA dismount force;" | sqlplus -s / as sysasm'
sudo su - grid -c 'echo "alter diskgroup ADR_FRA dismount force;" | sqlplus -s / as sysasm'

# SSH to PROD array to demote the PROD Pod
echo "About to demote the PROD Pod (read only)"
echo "purepod demote --quiesce ${PROD_POD}"
echo "Press return to contine..."
read me
ssh ${PROD_USER}@${PROD_ARRAY} "purepod demote --quiesce ${PROD_POD}"
sleep 3
ssh ${PROD_USER}@${PROD_ARRAY} "purepod list ${PROD_POD}"
echo
echo "PRODUCTION DATABASE ${PROD_DBNAME} SHUTDOWN, ASM DISMOUNTED, POD ${PROD_POD} DEMOTED" 
