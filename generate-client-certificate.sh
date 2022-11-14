#!/usr/bin/env bash

# Change to script directory
sd=`dirname $0`
cd $sd
sd=`pwd`

name=$1

if [ "$name" = "" ]; then
  echo "Usage: generate-client-certificate.sh name"
  exit;
fi

cd ~/openvpn-ca
yes "" | ./easyrsa gen-req ${name} nopass
cp pki/private/${name}.key ~/client-configs/keys/
yes "yes" | ./easyrsa sign-req client ${name}
cp /root/openvpn-ca/pki/issued/${name}.crt ~/client-configs/keys/
cp /etc/openvpn/server/ta.key ~/client-configs/keys/
cp /etc/openvpn/server/ca.crt ~/client-configs/keys/