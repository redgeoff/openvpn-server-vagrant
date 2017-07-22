#!/usr/bin/env bash

name=$1

if [ "$name" = "" ]; then
  echo "Usage: make-config.sh name"
  exit;
fi

cd ~/openvpn-ca
source vars

# And error ending in "ending in error 23" is expected
./revoke-full $name

# Install the revocation files
cp ~/openvpn-ca/keys/crl.pem /etc/openvpn
