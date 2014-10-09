#!/bin/bash

tflag=no
set -- $(getopt t "$@")
while [ $# -gt 0 ]
do
    case "$1" in
    (-t) tflag=yes;;
    (--) shift; break;;
    (-*) echo "$0: error - unrecognized option $1" 1>&2; exit 1;;
    (*)  break;;
    esac
    shift
done

read -p "Do you want to update? [y/N]? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get update
fi
sudo apt-get install python-dev vim screen
sudo pip install -r requirements.txt

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOME="$DIR/.."


read -p "Do you need to install bitcoind? [y/N]? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    wget --directory-prefix=$HOME https://bitcoin.org/bin/0.9.1/bitcoin-0.9.1-linux.tar.gz &&
    tar -C $HOME -zxvf $HOME/bitcoin-0.9.1-linux.tar.gz &&
    mv $HOME/bitcoin-0.9.1-linux $HOME/bitcoin &&
    rm $HOME/bitcoin-0.9.1-linux.tar.gz &&
    echo 'alias bitcoind=~/bitcoin/bin/64/bitcoin' >> $HOME/.bash_aliases &&
    source $HOME/.bash_aliases &&
    
    cp $DIR/src/settings_local.py.example $DIR/src/settings_local.py
fi


if [ "$tflag" == "yes" ]
then
  echo BITCOIND_TEST_MODE=True >> $DIR/src/settings_local.py
fi

mkdir -p $HOME/.bitcoin/
# this is harmless even if the file exists
touch $HOME/.bitcoin/bitcoin.conf

BTCRPC=`openssl rand -hex 32`
echo rpcuser=bitrpc >> $HOME/.bitcoin/bitcoin.conf
echo rpcpassword=$BTCRPC >> $HOME/.bitcoin/bitcoin.conf
if [ "$tflag" == "yes" ]
then
  echo connect=127.0.0.1:8333 >> $HOME/.bitcoin/bitcoin.conf
fi
echo BITCOIND_RPC_PASSWORD = \"$BTCRPC\" >> $DIR/src/settings_local.py
