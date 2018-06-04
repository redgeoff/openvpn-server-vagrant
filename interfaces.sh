#!/bin/bash

DEVICES=$(ifconfig -s | grep -v "Iface\|lo\|tun0" | cut -d " " -f 1)
NUMDEVICES=$(ifconfig -s | wc -l)
VPNDEVICE=""

# If we have an eth0 device, use that to maintain current functionality.
if ifconfig -s | grep -q eth0
then
  export VPNDEVICE="eth0"

# If we hit newer systemd/hypervisor combination, it won't be eth0, but there
# will probably be only one obvious device to use: not the loop back, and not
# the tunnel. Use it instead.
elif [ $NUMDEVICES -eq 3 ] 
  then
  # no eth0 device, but only one option, use it.
  export VPNDEVICE=$(ifconfig -s | tail -n 2 | cut -d " " -f 1 | grep -v "lo\|tun0")

else
  # If we end up on a server that has multiple devices and no eth0, just ask.
  # This is fairly common, Docker containers, wifi cards, dual nics, etc.
  echo "There are multiple network devices on this server:"
  echo ""
  ifconfig -s | grep -v "Iface\|lo\|tun0" | cut -d " " -f 1
  echo ""
  echo "Please type the name of the device you'd like to use"
  read VPNDEVICE

  # Catch bad user input  
  while ! echo $DEVICES | grep -q "${VPNDEVICE}"
  do
    echo "${VPNDEVICE} was not found in the list of devices. Please type the device name again"
    read VPNDEVICE
  done
  export $VPNDEVICE

fi
