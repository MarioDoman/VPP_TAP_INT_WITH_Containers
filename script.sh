#!/bin/bash

if [ $USER != "root" ] ; then
    echo "Restarting script with sudo..."
    sudo $0 ${*}
    exit
fi

sudo apt-get update
curl -s https://packagecloud.io/install/repositories/fdio/release/script.deb.sh | sudo bash
sudo apt-get update
sudo apt-get -y install vpp vpp-plugin-core vpp-plugin-dpdk iperf apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt update
sudo apt-get -y install docker-ce

sudo mkdir /var/run/netns

# logs for unittest outputs
sudo mkdir logs

# veth pair for docker1
sudo ip link add veth10 type veth peer name veth11
sudo ip link set veth10 up
sudo ip link set veth11 up

# veth pair for docker2
sudo ip link add veth20 type veth peer name veth21
sudo ip link set veth20 up
sudo ip link set veth21 up

#Create docker containers
docker pull ubuntu
docker run --name "docker1" ubuntu sleep 30000 &
docker run --name "docker2" ubuntu sleep 30000 &

#Wait for containers
sleep 10

#Expose containers to the 'ip netns exec' tools
pid1=`docker inspect -f '{{.State.Pid}}' docker1`
ln -s /proc/$pid1/ns/net /var/run/netns/docker1

pid2=`docker inspect -f '{{.State.Pid}}' docker2`
ln -s /proc/$pid2/ns/net /var/run/netns/docker2

# Move the veth10 into docker1 network namespace respectivley.
ip link set veth10 netns docker1
ip netns exec docker1 ip addr add 192.168.1.2/24 dev veth10
ip netns exec docker1 ip link set veth10 up
ip netns exec docker1 ip route add 192.168.2.0/24 via 192.168.1.1
ip netns exec docker1 ip route add 192.168.3.0/24 via 192.168.1.1

# Move the veth20 into docker1 network namespace respectivley.
ip link set veth20 netns docker2
ip netns exec docker2 ip addr add 192.168.3.2/24 dev veth20
ip netns exec docker2 ip link set veth20 up
ip netns exec docker2 ip route add 192.168.2.0/24 via 192.168.3.1
ip netns exec docker2 ip route add 192.168.1.0/24 via 192.168.3.1

# connect veth on the host to vpp
vppctl create host-interface name veth11
vppctl set int ip address host-veth11 192.168.1.1/24
vppctl set int state host-veth11 up

# connect veth on the host to vpp
vppctl create host-interface name veth21
vppctl set int ip address host-veth21 192.168.3.1/24
vppctl set int state host-veth21 up

# Create vpp tap interface
vppctl create tap
vppctl set interface state tap0 up
vppctl set interface ip address tap0 192.168.2.1/24

#Assign tap interface address on kernel interface
sudo ip addr add 192.168.2.2/24 dev tap0
sudo ip link set tap0 up

# Add routing from host to containers via tap
ip route add 192.168.1.0/24 via 192.168.2.1
ip route add 192.168.3.0/24 via 192.168.2.1

# Start iperf server on hostvm
iperf -sDB 192.168.2.2

sudo docker exec docker1 apt update
sudo docker exec docker1 apt -y install iputils-ping net-tools iperf
docker exec docker1 iperf -s -D

sudo docker exec docker2 apt update
sudo docker exec docker2 apt -y install iputils-ping net-tools iperf
docker exec docker2 iperf -s -D
