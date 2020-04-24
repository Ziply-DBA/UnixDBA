#!/bin/bash
if [ $# -lt 2 ]
then
        echo "Usage: $0 su_name password"
        exit 1
fi
file=`ls ~/$1_inventory.txt`

if [ -s "$file" ]
 then
    echo "Reading from $file "
 else
    echo "$file does not exist, or is empty "
    exit 1
 fi
cp /dev/null test_$1.out
for host in `cat $file`; do
   ./test_sudo.sh $LOGNAME $1 $2 $host  >> test_$1.out
done
