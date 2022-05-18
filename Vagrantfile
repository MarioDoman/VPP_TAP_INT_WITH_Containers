# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "bento/ubuntu-20.04"

Vagrant.configure("2") do |config|
  config.vm.define "vagrant" do |subconfig|
    subconfig.vm.box = BOX_IMAGE
    subconfig.vm.hostname = "vagrant"
    subconfig.vm.provision "shell", path: "script.sh", run: 'always'
    subconfig.vm.provision "file", source: "tests_unittest.py", destination: "tests_unittest.py"
    subconfig.vm.provision "file", source: "tests_lib.py", destination: "tests_lib.py"
    subconfig.vm.provision :shell, :inline => "python3 tests_unittest.py -v"
  end
end
