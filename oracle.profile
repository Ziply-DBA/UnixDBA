# DBA's aren't particularly good about leaving /var/opt/oracle/oratab 
# readable so the new kids on the server can find the installed binaries
# to set in their PATH, ORACLE_HOME, etc. 
#
# In this example, we figure it all out upon login

# Some customization may be needed to filter out certain product paths, SIDs, etc
# depending on your enterprise's standards

ORACLE_VERSION=`ls -ra /apps/u01/app/oracle/product | head -1`
export ORACLE_HOME=/apps/u01/app/oracle/product/$ORACLE_VERSION/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_SID=`ps -ef | grep smon | sed 's/ora_smon_//g' | grep -v sed | grep -v grep  | awk '{print $NF}' | head -1`
