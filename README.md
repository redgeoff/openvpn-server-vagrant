# openvpn-server-vagrant

Spin up an OpenVPN Server


## Install Vagrant, VirtualBox and git

    http://www.vagrantup.com
    https://www.virtualbox.org (don't worry about setting up any VMs as the steps below will cover this)
    http://git-scm.com


## Set up

    Edit /etc/hosts locally and add `192.168.50.11 vpn.dev`
    $ git clone https://github.com/redgeoff/openvpn-server-vagrant.git
    $ cd openvpn-server-vagrant
    $ cp config-default.sh config.sh
    Edit config.sh and fill in your config
    $ vagrant up
    $ vagrant ssh


# Generate a client config

The following should be repeated for each new client/user for whom you wish to grant access to your VPN. Replace client-name with a unique name.

    $ sudo /vagrant/make-config.sh client-name

You will then find a file like the following that you should provide to the individual who will be connecting to your VPN.

    ~client-configs/files/client-name.ovpn


# Revoke client certificate

If you ever need to revoke access, simply execute:

    $ sudo /vagrant/revoke-full.sh client-name


## Extra Info

See [How To Set Up an OpenVPN Server on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-openvpn-server-on-ubuntu-16-04)
