#!/usr/bin/env bash

# First argument: Client identifier

name=$1

KEY_DIR=~/openvpn-ca/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.conf

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${name}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${name}.key \
    <(echo -e '</key>\n<tls-auth>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-auth>') \
    > ${OUTPUT_DIR}/${name}.ovpn

# sed -i "s/group nogroup/group nobody/" ${OUTPUT_DIR}/${name}.ovpn
