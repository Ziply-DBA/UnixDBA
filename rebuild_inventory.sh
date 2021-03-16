#!/bin/bash
# Build the inventory.yaml file based on data
. ~/.bash_profile
sqlplus /nolog << EOF
conn $OVERDRIVE_CONN
@inventory
EOF

#create carriage returns in place of ##
cat inventory.lst | sed 's/##/\
/g' > inventory.out

#remove trailing spaces
sed -i 's/[[:space:]]*$//' inventory.out

echo "all:" > inventory.yaml
echo "  children:" >> inventory.yaml
#remove blank lines
cat inventory.out | grep -v -e '^[[:space:]]*$'  >> inventory.yaml
rm inventory.out inventory.lst
