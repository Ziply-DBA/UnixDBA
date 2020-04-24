#!/bin/bash
if [ $# -lt 1 ]
then
        echo "Usage: $0 password"
        exit 1
fi
$file=~/host_inventory.txt

if [ -s "$file" ]
 then
    echo "Reading from $file "
 else
    echo "$file does not exist, or is empty "
    exit 1
 fi
cp /dev/null push.out
for host in `cat ~/host_inventory.txt`; do
   ./push_key.sh $LOGNAME $1 $host  >> push.out
done
