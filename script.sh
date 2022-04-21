#!/bin/bash

if [ $USER != "root" ] ; then
    echo "Restarting script with sudo..."
    sudo $0 ${*}
    exit
fi

dockerrmf () {
	#Cleanup all containers on the host (dead or alive).
	docker kill `docker ps --no-trunc -aq` ; docker rm `docker ps --no-trunc -aq`
}

#Vagrant build box initial setup
if [ -a /etc/apt/sources.list.d/docker.list ]
        then
            echo "Docker APT Sources already configured. Not setting up Docker on this Vagrant Box"
						echo "Cleaning up containers from previous run..."
						dockerrmf
        else
            mkdir /var/run/netns
            sudo apt-get update
            sudo apt-get -y install ca-certificates curl gnupg lsb-release
            echo "deb [trusted=yes] https://packagecloud.io/fdio/release/ubuntu bionic main" | sudo tee /etc/apt/sources.list.d/99fd.io.list
            sudo curl -L https://packagecloud.io/fdio/release/gpgkey | sudo apt-key add -
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update
            sudo apt-get -y install docker-ce docker-ce-cli containerd.io vpp vpp-plugin-core vpp-plugin-dpdk python3-vpp-api vpp-dbg vpp-dev vpp-ext-deps iperf
fi

echo "Remove old netns simlink"
sudo rm -Rf /var/run/netns
sudo mkdir /var/run/netns

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

#TEST!
echo "Pinging container1 via host > TAP-VPP > Container1"
ping -c3 192.168.1.2

echo "Pinging container2 via host > TAP-VPP > Container2"
ping -c3 192.168.3.2

sudo docker exec docker1 apt update
sudo docker exec docker1 apt -y install iputils-ping net-tools iperf
echo "Ping from container1 via container > VPP-TAP > Host"
docker exec docker1 ping -c3 192.168.2.2
docker exec docker1 iperf -s -D
sudo docker exec docker2 apt update
sudo docker exec docker2 apt -y install iputils-ping net-tools iperf
echo "Ping from container2 via container > VPP-TAP > Host"
docker exec docker2 ping -c3 192.168.2.2
docker exec docker2 iperf -s -D
echo "Ping from Container1 to Container2 via VPP"
docker exec docker1 ping -c3 192.168.3.2
