#! /bin/sh

# multi-pool startup script 
#
# Install the library 
#
# by Ice00
#
# (C) 2014 Ice Team
#
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

BASE_DIR=/opt/multi-pool
 
# update the server
sudo apt-get update
sudo apt-get dist-upgrade

# install the library   
sudo apt-get install git
sudo apt-get install build-essential libboost-all-dev libcurl4-openssl-dev libdb5.1-dev libdb5.1++-dev
# add specific library
#sudo apt-getapt-get install libboost1.48-all-dev

# statum mining  
sudo apt-get install python-twisted python-mysqldb python-dev python-setuptools python-memcache python-simplejson
easy_install -U distribute

# mpos library   
sudo apt-get install memcached php5-memcached php5-mysqlnd php5-curl php5-json libapache2-mod-php5
sudo apache2ctl -k stop; sleep 2; sudo apache2ctl -k start

# add mail server
sudo apt-get install postfix

# make all the tree

cd $BASE_DIR

mkdir coin
mkdir bin
mkdir src
mkdir mpos
mkdir stratum
mkdir wallet

# install stratum and litecoin

cd $BASE_DIR/stratum
git clone https://github.com/Tydus/litecoin_scrypt.git
git clone https://github.com/ahmedbodi/stratum.git
git clone https://github.com/scr34m/vertcoin_scrypt

cd $BASE_DIR/stratum/litecoin_scrypt
python setup.py install

cd $BASE_DIR/stratum/stratum
python setup.py install

cd $BASE_DIR/stratum/vertcoin_scrypt
python setup.py install


groupadd coind
useradd coind -d /opt/multi-pool/bin -s /bin/false -g coind

# copy all the stuff exatracted from the zip to bin directory
cp * $BASE_DIR/bin