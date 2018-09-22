Vagrant.configure("2") do |config|

  config.vm.box = "https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64-vagrant.box"

  # Use a private network so that we don't have to worry about forwarding ports
  config.vm.network "private_network", ip: "192.168.50.11"

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024

    # Only allow drift of 1 sec, instead of 20 min default
    v.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 1000 ]
  end

  # Bootstrap script for configuring VM
  config.vm.provision :shell, path: "bootstrap.sh"

end
