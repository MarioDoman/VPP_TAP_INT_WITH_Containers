# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "bento/ubuntu-18.04"

Vagrant.configure("2") do |config|
  config.vm.define "vagrant" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = "vagrant"
    subconfig.vm.provision "shell", path: "script.sh", run: 'always'
  end
end
