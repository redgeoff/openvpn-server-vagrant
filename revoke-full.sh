#!/usr/bin/env bash

name=$1

if [ "$name" = "" ]; then
  echo "Usage: revoke-full.sh name"
  exit;
fi

cd ~/openvpn-ca

yes "yes" | ./easyrsa revoke $name

./easyrsa gen-crl

# Install the revocation files
cp pki/crl.pem /etc/openvpn/server

# Configure the server to check the client revocation list. This should only be done once
if [ $(grep -R 'crl-verify crl.pem' /etc/openvpn/server/server.conf | wc -l) -eq 0 ]; then
  echo -e "\ncrl-verify crl.pem" >> /etc/openvpn/server/server.conf
  systemctl restart openvpn-server@server.service
fi
