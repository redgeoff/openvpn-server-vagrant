# openvpn-server-vagrant

Spin up an OpenVPN Server


## Install Vagrant, VirtualBox and git

    http://www.vagrantup.com
    https://www.virtualbox.org (don't worry about setting up any VMs as the steps below will cover this)
    http://git-scm.com


## Set up

    $ git clone https://github.com/redgeoff/openvpn-server-vagrant.git
    $ cd openvpn-server-vagrant
    $ cp config-default.sh config.sh
    Edit config.sh and fill in your config
    $ vagrant up
    $ vagrant ssh

You can then perform a sanity test with a connection from a VPN client with:

    $ sudo su -
    $ /vagrant/add-client.sh test-client
    $ cp ~/client-configs/files/test-client.ovpn /vagrant
    On the host, double click `test-client.ovpn` to load it into Tunnelblick
    Use Tunnelblick to connect to the VPN server

# Add a route to a subnet

Routes must be added to the server so that you clients know which traffic to route to the VPN Server. The following process should be repeated for each subnet in your network.

Edit `/etc/openvpn/server.conf` and add something like the following, where `172.31.26.0` is your network and 255.255.255.0 is the netmask.

    push "route 172.31.26.0 255.255.255.0"

Then restart the VPN Server:

    $ sudo systemctl restart openvpn@server


## Add a client

The following should be repeated for each new client/user for whom you wish to grant access to your VPN. Replace client-name with a unique name.

    $ sudo su -
    $ /vagrant/add-client.sh client-name

You will then find a file like the following that you should provide to the individual who will be connecting to your VPN. This ovpn file can then be used with Tunnelblick (OS X), OpenVPN (Linux, iOS, Android and Windows).

    ~/client-configs/files/client-name.ovpn


## Revoke client certificate

If you ever need to revoke access, simply execute:

    $ sudo su -
    $ /vagrant/revoke-full.sh client-name


## Extra Info

* See [Using a VPN Server to Connect to Your AWS VPC for Just the Cost of an EC2 Nano Instance](https://redgeoff.com/posts/running-a-free-vpn-server-on-aws/)
* See [How To Set Up and Configure an OpenVPN Server on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-and-configure-an-openvpn-server-on-ubuntu-20-04)
