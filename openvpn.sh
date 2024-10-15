#!/usr/bin/env bash

# For details on why certain options have been chosen, see
# https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-ubuntu-20-04

# Change to script directory
sd=`dirname $0`
cd $sd
# if you ran the script from its own directory you actually just got '.'
# so capture the abs path to wd now
sd=`pwd`

# Make sure config file exists
if [ ! -f ./config.sh ]; then
  echo "config.sh not found!"
  exit;
fi

# Install OpenVPN and net-tools (ifconfig)
apt-get -y install openvpn easy-rsa net-tools

# Load config
source ./config.sh
source ./interfaces.sh

# Set up the CA directory
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Update vars
echo "set_var EASYRSA_REQ_COUNTRY    \"${KEY_COUNTRY}\"" >> vars
echo "set_var EASYRSA_REQ_PROVINCE   \"${KEY_PROVINCE}\"" >> vars
echo "set_var EASYRSA_REQ_CITY       \"${KEY_CITY}\"" >> vars
echo "set_var EASYRSA_REQ_ORG        \"${KEY_ORG}\"" >> vars
echo "set_var EASYRSA_REQ_EMAIL      \"${KEY_EMAIL}\"" >> vars
echo "set_var EASYRSA_REQ_OU         \"${KEY_OU}\"" >> vars
echo "set_var EASYRSA_ALGO         \"ec\"" >> vars
echo "set_var EASYRSA_DIGEST         \"sha512\"" >> vars

# Build the Certificate Authority
./easyrsa init-pki
yes "" | ./easyrsa build-ca nopass

# Create the server certificate
yes "" | ./easyrsa gen-req server nopass
cp pki/private/server.key /etc/openvpn/
cp pki/private/ca.key /etc/openvpn/
cp pki/ca.crt /etc/openvpn/

# Sign the certificate request
yes "yes" | ./easyrsa sign-req server server
yes "yes" | cp pki/issued/server.crt /etc/openvpn/

# Generate an extra shared secret key
openvpn --genkey secret pki/ta.key
cp pki/ta.key /etc/openvpn/

# Copy the sample config to the OpenVPN directory
cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server.conf

# Adjust the OpenVPN configuration
sed -i "s/^;tls-crypt ta.key.*$/tls-crypt ta.key 0/" /etc/openvpn/server.conf
# sed -i "s/cipher AES-256-CBC/cipher AES-256-GCM\nauth SHA256/" /etc/openvpn/server.conf
sed -i "s/dh dh2048.pem/;dh dh2048.pem\ndh none/" /etc/openvpn/server.conf
# sed -i "s/;user openvpn/user openvpn/" /etc/openvpn/server.conf
# sed -i "s/;group openvpn/group openvpn/" /etc/openvpn/server.conf

# Allow IP forwarding
sed -i "s/#net.ipv4.ip_forward/net.ipv4.ip_forward/" /etc/sysctl.conf
sysctl -p

# Firewall configuration
sed -i "s/# rules.before/# rules.before\n# START OPENVPN RULES\n# NAT table rules\n*nat\n:POSTROUTING ACCEPT [0:0]\n-A POSTROUTING -s 10.8.0.0\/8 -o ${VPNDEVICE} -j MASQUERADE\nCOMMIT\n# END OPENVPN RULES/" /etc/ufw/before.rules
sed -i "s/DEFAULT_FORWARD_POLICY=\"DROP\"/DEFAULT_FORWARD_POLICY=\"ACCEPT\"/" /etc/default/ufw
ufw allow 1194/udp
ufw allow OpenSSH
ufw disable
yes "y" | ufw enable

# Start and enable the OpenVPN service
systemctl -f enable openvpn-server@server.service
systemctl start openvpn-server@server.service

# Creating the Client Configuration Infrastructure
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs
mkdir -p ~/client-configs/files
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf
sed -i "s/remote my-server-1 1194/remote ${PUBLIC_IP} 1194/" ~/client-configs/base.conf
# sed -i "s/;user openvpn/user openvpn/" ~/client-configs/base.conf
# sed -i "s/;group openvpn/group openvpn/" ~/client-configs/base.conf
sed -i "s/ca ca.crt/;ca ca.crt/" ~/client-configs/base.conf
sed -i "s/cert client.crt/;cert client.crt/" ~/client-configs/base.conf
sed -i "s/key client.key/;key client.key/" ~/client-configs/base.conf
sed -i "s/tls-auth ta.key 1/;tls-auth ta.key 1/" ~/client-configs/base.conf
# sed -i "s/cipher AES-256-CBC/cipher AES-256-GCM/" ~/client-configs/base.conf
echo "auth SHA256" >> ~/client-configs/base.conf
echo "key-direction 1" >> ~/client-configs/base.conf
echo ";script-security 2" >> ~/client-configs/base.conf
echo ";up /etc/openvpn/update-resolv-conf" >> ~/client-configs/base.conf
echo ";down /etc/openvpn/update-resolv-conf" >> ~/client-configs/base.conf
echo ";script-security 2" >> ~/client-configs/base.conf
echo ";up /etc/openvpn/update-systemd-resolved" >> ~/client-configs/base.conf
echo ";down /etc/openvpn/update-systemd-resolved" >> ~/client-configs/base.conf
echo ";down-pre" >> ~/client-configs/base.conf
echo ";dhcp-option DOMAIN-ROUTE ." >> ~/client-configs/base.conf
