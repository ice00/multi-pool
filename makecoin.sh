#! /bin/sh

# multi-pool script
#
# Make one coin
#
# by Ice00
#
# (C) 2014 Ice Team

# Directory structure:
#
# /opt/multi-pool/
#  script/             multi-pool script
#  coin/               coin definitions (each subdirectory=a coin sigle)
#  bin/                binary of daemon
#  src/                source of daemon (each subdirectory=a coin sigle)
#  mpos/               mpos (each directory=a coin sigle)
#  statum/             statum (each directory=a coin sigle)
#  wallet/             wallet (each directory=a coin sigle)
 

# change those according with the coin to create
COIN_NAME=incakoin
COIN_PREF_LOW=nka
COIN_PREF_HIGH=NKA
BIN_DAEMON=IncaKoind
SRC_PATH=IncaKoin
SRC_GITHUB=https://github.com/madross/IncaKoin
COIN_CONFIG=IncaKoin.conf


BASE_DIR=/opt/multi-pool

#### MAKE COIN DIRECTORY ###

cd $BASE_DIR/coin

mkdir $COIN_PREF_LOW
chmod 700 $COIN_PREF_LOW


##### COMPILE the DAEMON #####

cd $BASE_DIR/src

# get the source
git clone $SRC_GITHUB

cd $BASE_DIR/src/$SRC_PATH

# some build need this directory and permission
mkdir src/obj
chmod 755 src/leveldb/build_detect_platform

cd $BASE_DIR/src/$SRC_PATH/src


# compile the daemon
make -f makefile.unix USE_UPNP=-

# copy executable into binary directory
cp $BIN_DAEMON ../../../bin

# change permission to the daemon to not run as root
chown coind $BASE_DIR/bin/$BIN_DAEMON
chgrp coind $BASE_DIR/bin/$BIN_DAEMON
chmod 6755 $BASE_DIR/bin/$BIN_DAEMON


# go to root directory of multi-pool
cd $BASE_DIR/


##### INSTALL MPOS #####

cd mpos

mkdir $COIN_PREF_LOW
git clone git://github.com/TheSerapher/php-mpos.git $COIN_PREF_LOW
cd $COIN_PREF_LOW
git checkout master

# Create database
echo "Insert the root password for mysql"
mysql -p -e "create database ${COIN_PREF_LOW};"
mysql -p -e "create user \'${COIN_PREF_LOW}\'@\'localhost\' identified by \'${COIN_PREF_LOW}${COIN_PREF_LOW}${COIN_PREF_LOW}\';"
mysql -p -e "grant all privileges on ${COIN_PREF_LOW}.* TO \'${COIN_PREF_LOW}\'@\'localhost\';"
# Import structure
echo "Insert the ${COIN_PREF_LOW} password for mysql"
mysql -u $COIN_PREF_LOW -p ${COIN_PREF_LOW} < sql/000_base_structure.sql

#make permission
cd ..
chown www-data ${COIN_PREF_LOW}/templates/compile ${COIN_PREF_LOW}/templates/cache ${COIN_PREF_LOW}/logs

# create configuration file 
cp $BASE_DIR/mpos/$COIN_PREF_LOW/include/config/global.inc.dist.php  $BASE_DIR/mpos/$COIN_PREF_LOW/include/config/global.inc.php


# WALLET

# create wallet directory with custon permission
cd $BASE_DIR/wallet
mkdir $COIN_PREF_LOW
chown coind $COIN_PREF_LOW
chgrp coind $COIN_PREF_LOW

cd $BASE_DIR/wallet/$COIN_PREF_LOW

# create empty coin configuration file
echo  "
rpcuser=
rpcpassword=
rpcport=
server=1
addnode=
" > ./$COIN_CONFIG

##### INSTALL Statum #####

cd $BASE_DIR/stratum

mkdir $COIN_PREF_LOW
cd $COIN_PREF_LOW

git clone https://github.com/Crypto-Expert/stratum-mining.git


# activate the cron scripts for this coin

cd $BASE_DIR/script
echo "nice -n 19 $BASE_DIR/mpos/$COIN_PREF_LOW/run-statistics.sh -d $COIN_PREF_HIGH\n" >> crons_fast.sh
echo "nice -n 19 $BASE_DIR/mpos/$COIN_PREF_LOW/run_maintenance.sh -d $COIN_PREF_HIGH\n" >> crons_fast.sh
echo "nice -n 19 $BASE_DIR/mpos/$COIN_PREF_LOW/run_payout.sh -d $COIN_PREF_HIGH\n" >> crons_slow.sh
echo "nice -n 19 $BASE_DIR/mpos/$COIN_PREF_LOW/run-crons.sh -d $COIN_PREF_HIGH\n" >> crons.sh

# make the startup script for this coin


echo  "
#!/bin/bash
#
# $COIN_PREF_LOW - $COIN_NAME
RETVAL=0;

start() {
echo \"Starting $COIN_PREF_HIGH\"
$BASE_DIR/bin/$BIN_DAEMON -datadir=$BASE_DIR/wallet/$COIN_PREF_LOW/  &
sleep 2
cd $BASE_DIR/stratum/$COIN_PREF_LOW/stratum-mining/
twistd -y launcher.tac &
}

stop() {
echo \"Stopping $COIN_PREF_HIGH\"
kill -15 \$(cat $BASE_DIR/stratum/$COIN_PREF_LOW/stratum-mining/twistd.pid)
sleep 1
kill -9 \$(cat $BASE_DIR/stratum/$COIN_PREF_LOW/stratum-mining/twistd.pid)
$BASE_DIR/bin/$BIN_DAEMON -datadir=$BASE_DIR/wallet/$COIN_PREF_LOW/ stop
}

restart() {
stop
start
}

case \"$1\" in
start)
  start
;;
stop)
  stop
;;
restart)
  restart
;;
*)

echo $\"Usage: $0 {start|stop|restart}\"
exit 1
esac

exit $RETVAL  

" >> /etc/init.d/coin_$COIN_PREF_LOW

chmod 755 /etc/init.d/coin_$COIN_PREF_LOW
chmod +x /etc/init.d/coin_$COIN_PREF_LOW

# activate it
update-rc.d coin_$COIN_PREF_LOW defaults

# save the information about this coin in coin directory
cd $BASE_DIR/coin/$COIN_PREF_LOW

echo "
COIN_NAME=$COIN_NAME
COIN_PREF_LOW=$COIN_PREF_LOW
COIN_PREF_HIGH=$COIN_PREF_HIGH
BIN_DAEMON=$BIN_DAEMON
SRC_PATH=$SRC_PATH
SRC_GITHUB=$SRC_GITHUB
COIN_CONFIG=$COIN_CONFIG
" > ./$COIN_PREF_LOW.txt

# create symbolic link for easy coin configuration management
ln -s $BASE_DIR/wallet/$COIN_PREF_LOW/$COIN_CONFIG ./$COIN_CONFIG
ln -s $BASE_DIR/mpos/$COIN_PREF_LOW/include/config/global.inc.php ./global.inc.php
ln -s $BASE_DIR/stratum/$COIN_PREF_LOW/stratum-mining/conf/config.py ./config.py
