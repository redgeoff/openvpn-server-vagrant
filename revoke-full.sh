#!/usr/bin/env bash

name=$1

if [ "$name" = "" ]; then
  echo "Usage: revoke-full.sh name"
  exit;
fi

cd ~/openvpn-ca
source vars

# An error ending in "ending in error 23" is expected
./revoke-full $name

# Install the revocation files
cp ~/openvpn-ca/keys/crl.pem /etc/openvpn

# Configure the server to check the client revocation list. This should only be done once
if [ $(grep -R 'crl-verify crl.pem' /etc/openvpn/server.conf | wc -l) -eq 0 ]; then
  echo "crl-verify crl.pem" >> /etc/openvpn/server.conf
  systemctl restart openvpn@server
fi
