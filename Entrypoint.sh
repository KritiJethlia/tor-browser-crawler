#!/bin/bash

# configures and runs a crawl (inside a docker container)

# globals
PYTHON_VERSION='python3.7'
PYTHON_PATH=`which $PYTHON_VERSION`
TOR_VERSION='9.5.1'
BASE='/home/docker/tbcrawl'

# set offloads
ifconfig eth0 mtu 1500
ethtool -K eth0 tx off rx off tso off gso off gro off lro off

# install python requirements
pushd ${BASE}
pip3 install -U -r requirements.txt

# copy tor browser bundle
rm -rf tor-browser_en-US
cp -r /home/docker/tbb_setup/tor-browser_en-US .

# TODO: do other stuff here if you need to
# Run command with params
python3.7 bin/tbcrawler.py $1
