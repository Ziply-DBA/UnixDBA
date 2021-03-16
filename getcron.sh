#!/bin/bash
. ~/.bash_profile
. ~/ziply.profile
STATUS=OK
DIR=`dirname "$0"`
cd $DIR
./rebuild_inventory.sh
[[ $? -eq 0 ]] || STATUS=ERROR

export ANSIBLE_PYTHON_INTERPRETER=auto_silent
unset  ANSIBLE_STDOUT_CALLBACK
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook getcron.yaml -i inventory.yaml > all_cron.raw

#Filter the output for the cron entries
cat all_cron.raw | grep CRONTAB | sed 's/        "CRONTAB //' | sed 's/\", $//' | sed 's/\"$//'> all_cron.txt 2> /dev/null

#Filter out blank cron lines and compress double spaces to single
awk 'NF>2' all_cron.txt | sed 's/  / /g' | sed 's/  / /g' >all_cron.out
cat all_cron.out | sed 's/|/_PIPE_/g' | sed 's/ /|/g' | sed 's/|/ /8g' > all_cron.dat
sqlplus /nolog << EOF > /dev/null
conn $OVERDRIVE_CONN
truncate table load_cron;
EOF
[[ $? -eq 0 ]] || STATUS=ERROR
sqlldr userid=$OVERDRIVE_CONN control=cron.ctl data=all_cron.dat log=all_cron.log
[[ $? -eq 0 ]] || STATUS=ERROR
rm all_cron.dat  all_cron.txt all_cron.raw all_cron.out
sqlplus /nolog << EOF > /dev/null
conn $OVERDRIVE_CONN
update load_cron set hostname=replace(hostname,'.corp.pvt','');
update load_cron set hostname=replace(hostname,'.nw1.nwestnetwork.com','');
update load_cron set hostname=replace(hostname,'.nwestnetwork.com','') where hostname like '%.%'; 
update load_cron set host_id=(select min(host_id) from host where hostname=load_cron.hostname);
update load_cron set cron_cmd=replace(cron_cmd,'_PIPE_','|') where cron_cmd like '_PIPE_';


update global_cron g set upd_date=sysdate
where exists 
(select 'x' from load_cron l where
 l.HOST_ID = g.HOST_ID and
 l.USERNAME = 	 g.USERNAME and
 l.CRON_MIN = 	 g.CRON_MIN and
 l.CRON_HOUR= 	 g.CRON_HOUR and
 l.CRON_DOM = 	 g.CRON_DOM and
 l.CRON_MON =	 g.CRON_MON and
 l.CRON_DOW = g.CRON_DOW and
 l.CRON_CMD =	 g.CRON_CMD )
/

insert into global_cron (
 cron_id,
 HOST_ID  ,
 USERNAME , 
 CRON_MIN , 
 CRON_HOUR,  
 CRON_DOM , 
 CRON_MON , 
 CRON_DOW , 
 CRON_CMD  
)
select 
 rownum + m.maxID,
 l.HOST_ID  ,
 l.USERNAME , 
 l.CRON_MIN , 
 l.CRON_HOUR,  
 l.CRON_DOM , 
 l.CRON_MON , 
 l.CRON_DOW , 
 l.CRON_CMD  
from load_cron l, (select max(cron_id) as maxID from global_cron) m where 
 (l.HOST_ID  ,
 l.USERNAME , 
 l.CRON_MIN , 
 l.CRON_HOUR,  
 l.CRON_DOM , 
 l.CRON_MON , 
 l.CRON_DOW , 
 l.CRON_CMD    )
not in (select
 HOST_ID  ,
 USERNAME , 
 CRON_MIN , 
 CRON_HOUR,  
 CRON_DOM , 
 CRON_MON , 
 CRON_DOW , 
 CRON_CMD  
from global_cron)
/

EOF
[[ $? -eq 0 ]] || STATUS=ERROR
logger_function `basename "$0"` $STATUS
