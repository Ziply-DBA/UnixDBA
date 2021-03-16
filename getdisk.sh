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
ansible-playbook getdisk.yaml -i inventory.yaml > all_disk.raw

#Filter the output for the disk entries
cat all_disk.raw | grep DISKUSAGE | sed 's/        "DISKUSAGE //' | sed 's/\", $//' | sed 's/\"$//'> all_disk.txt 2> /dev/null

#Filter out blank disk lines and compress double spaces to single
cat all_disk.txt  | sed 's/     / /g'  | sed 's/   / /g' | sed 's/  / /g' | sed 's/  / /g' > all_disk.out
cat all_disk.out | sed 's/ /|/g' | sed 's/||/|/g' | sed 's/||/|/g' > all_disk.dat
sqlplus /nolog << EOF > /dev/null
conn $OVERDRIVE_CONN
truncate table load_disk;
EOF
[[ $? -eq 0 ]] || STATUS=ERROR
sqlldr userid=$OVERDRIVE_CONN control=disk.ctl data=all_disk.dat log=all_disk.log
[[ $? -eq 0 ]] || STATUS=ERROR
rm all_disk.dat  all_disk.txt all_disk.raw all_disk.out
sqlplus /nolog << EOF > /dev/null
conn $OVERDRIVE_CONN
update load_disk set hostname=replace(hostname,'.nw1.nwestnetwork.com','');
update load_disk set hostname=replace(hostname,'.nwestnetwork.com','') where hostname like '%.%'; 
update load_disk set host_id=(select min(host_id) from host where hostname=load_disk.hostname);
insert into unix_disk_history select * from load_disk;
EOF
[[ $? -eq 0 ]] || STATUS=ERROR
logger_function `basename "$0"` $STATUS
