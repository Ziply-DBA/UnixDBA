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
for host in `cat ~/host_inventory.txt`; do
   ./validate_password.sh $LOGNAME $1 $host  >> validate.out
done
