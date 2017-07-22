#!/usr/bin/env bash

# Change to script directory
sd=`dirname $0`
cd $sd

name=$1

if [ "$name" = "" ]; then
  echo "Usage: generate-client-certificate.sh name"
  exit;
fi

cd ~/openvpn-ca
source vars
$sd/build-key.sh $name
