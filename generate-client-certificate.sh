#!/usr/bin/env bash

name=$1

if [ "$name" = "" ]; then
  echo "Usage: generate-client-certificate name"
  exit;
fi

cd ~/openvpn-ca
source vars
yes "" | ./build-key $name
