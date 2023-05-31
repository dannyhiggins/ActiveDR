# ActiveDR
## ActiveDR demo scripts

Copy the scripts in the PROD directory to the Production Database Server in the /home/oracle/actdr_demo directory
Copy the scripts in the DR directory to the DR Database Server in the /home/oracle/actdr_demo directory

### DR Server:
**dr_inserts.bash** - Simple script to repeatedly insert and view latest rows on the DR database 
                - This will report errors while the Oracle-DR Pod is demoted as the database is unavailable
**dr_drill_start.bash** - Simple script to start a DR drill by promoting the Oracle-DR Pod, Mounting ASM disk groups and Starting the DR database
**dr_drill_end.bash**   - Simple script to end the DR drill by Stopping the DR database, dismounting the ASM disk groups and demoting the Oracle-DR Pod
**dr_controlled_failover.bash** - Stop Production Databae, Demote Oracle-PROD Pod, Promote Oracle-DR Pod              


### PROD Server
**prod_inserts.bash** - Simple script to repeatedly insert and view latest rows on the PROD database

