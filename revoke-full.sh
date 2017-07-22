#!/usr/bin/env bash

# Usage: revoke-full.sh client-name

cd ~/openvpn-ca
source vars

# And error ending in "ending in error 23" is expected
./revoke-full $1

# TODO: should this be done during the setup??
# Install the revocation files
# cp ~/openvpn-ca/keys/crl.pem /etc/openvpn
# echo "crl-verify crl.pem" >> /etc/openvpn/server.conf
# systemctl restart openvpn@server
