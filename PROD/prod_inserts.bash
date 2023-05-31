#/bin/bash
# Simple script to insert rows and list them for monitoring ActiveDR behaviour 
# Pre-reqs: The USERS.PUREROWS table must exist 
#CREATE USER "PUREUSER" PROFILE "DEFAULT" IDENTIFIED BY "PUREUSER123"
#DEFAULT TABLESPACE "USERS" TEMPORARY TABLESPACE "TEMP1"
#QUOTA UNLIMITED ON "USERS" ACCOUNT UNLOCK;
#
#GRANT "CONNECT" TO "PUREUSER";
#GRANT "RESOURCE" TO "PUREUSER";
#create table PUREUSER.PUREROWS (
#  "TIMESTAMP" TIMESTAMP,
#  DETAILS VARCHAR2(60)
#) TABLESPACE USERS;	


export SITE=PROD

function insert_select {
echo "set pages 120 lines 150
col TIMESTAMP form a30
insert into PUREUSER.PUREROWS values (SYSDATE, '1 row insterted at $SITE site at ' || sysdate);
SELECT *
   FROM (SELECT *
          FROM PUREUSER.PUREROWS
         ORDER BY TIMESTAMP DESC
        )
WHERE ROWNUM <= 10;" | sqlplus -s / as sysdba
}


while true
do
	clear
	insert_select
	sleep 3
done
