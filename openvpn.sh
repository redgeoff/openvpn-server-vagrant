#!/usr/bin/env bash

# Change to script directory
sd=`dirname $0`
cd $sd

# Make sure config file exists
if [ ! -f ./config.sh ]; then
  echo "config.sh not found!"
  exit;
fi

# Load config
source ./config.sh

# Install OpenVPN and expect
apt-get -y install openvpn easy-rsa expect

# Set up the CA directory
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Update vars
sed -i "s/export KEY_COUNTRY=\"[^\"]*\"/export KEY_COUNTRY=\"${KEY_COUNTRY}\"/" vars
sed -i "s/export KEY_PROVINCE=\"[^\"]*\"/export KEY_PROVINCE=\"${KEY_PROVINCE}\"/" vars
sed -i "s/export KEY_CITY=\"[^\"]*\"/export KEY_CITY=\"${KEY_CITY}\"/" vars
sed -i "s/export KEY_ORG=\"[^\"]*\"/export KEY_ORG=\"${KEY_ORG}\"/" vars
sed -i "s/export KEY_EMAIL=\"[^\"]*\"/export KEY_EMAIL=\"${KEY_EMAIL}\"/" vars
sed -i "s/export KEY_OU=\"[^\"]*\"/export KEY_OU=\"${KEY_OU}\"/" vars
sed -i "s/export KEY_NAME=\"[^\"]*\"/export KEY_NAME=\"server\"/" vars

# Build the Certificate Authority
source vars
./clean-all
yes "" | ./build-ca

# Create the server certificate, key, and encryption files
$sd/build-key-server.sh
./build-dh
openvpn --genkey --secret keys/ta.key

# Copy the files to the OpenVPN directory
cd ~/openvpn-ca/keys
cp ca.crt ca.key server.crt server.key ta.key dh2048.pem /etc/openvpn
gunzip -c /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz | sudo tee /etc/openvpn/server.conf

# Adjust the OpenVPN configuration
sed -i "s/;tls-auth ta.key 0/tls-auth ta.key 0\nkey-direction 0/" /etc/openvpn/server.conf
sed -i "s/;cipher AES-128-CBC/cipher AES-128-CBC\nauth SHA256/" /etc/openvpn/server.conf
sed -i "s/;user nobody/user nobody/" /etc/openvpn/server.conf
sed -i "s/;group nogroup/group nogroup/" /etc/openvpn/server.conf

# Allow IP forwarding
sed -i "s/#net.ipv4.ip_forward/net.ipv4.ip_forward/" /etc/sysctl.conf
sysctl -p

# Install iptables-persistent so that rules can persist across reboots
apt-get -y iptables-persistent

# Edit iptables rules to allow for forwarding
iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Make iptables rules persistent across reboots
iptables-save > /etc/iptables/rules.v4

# Start and enable the OpenVPN service
systemctl start openvpn@server
systemctl enable openvpn@server

# Create the client config directory structure
mkdir -p ~/client-configs/files

# Create a base configuration
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf ~/client-configs/base.conf
sed -i "s/remote my-server-1 1194/remote ${PUBLIC_IP} 1194/" ~/client-configs/base.conf
sed -i "s/;user nobody/user nobody/" ~/client-configs/base.conf
sed -i "s/;group nogroup/group nogroup/" ~/client-configs/base.conf
sed -i "s/ca ca.crt/#ca ca.crt/" ~/client-configs/base.conf
sed -i "s/cert client.crt/#cert client.crt/" ~/client-configs/base.conf
sed -i "s/key client.key/#key client.key/" ~/client-configs/base.conf
echo "cipher AES-128-CBC" >> ~/client-configs/base.conf
echo "auth SHA256" >> ~/client-configs/base.conf
echo "key-direction 1" >> ~/client-configs/base.conf
echo "#script-security 2" >> ~/client-configs/base.conf
echo "#up /etc/openvpn/update-resolv-conf" >> ~/client-configs/base.conf
echo "#down /etc/openvpn/update-resolv-conf" >> ~/client-configs/base.conf
