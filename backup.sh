#! /bin/bash

# multi-pool backup script 
#
# Backup all of interesting 
#
# by Ice00
#
# (C) 2014 Ice Team

BASE_DIR=/opt/multi-pool

coins=( $(find $BASE_DIR/coin -maxdepth 1 -type d -printf '%P\n') )
 
# update the server
cd /tmp
mkdir backup
cd backup

for i in "${coins[@]}"
do
  mkdir $i
  cd $i
  cp $BASE_DIR/coin/$i/*.* ./
  cp $BASE_DIR/wallet/$i/wallet.dat ./
  mysqldump $i -u $i --password=$i$i$i > ./$i.sql
  cd ..
done

cd /tmp
tar -zcvf backup.tar.gz ./backup