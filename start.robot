*** Settings ***
Library    Process    
Library    OperatingSystem
Library    String


*** Test Cases *** 
Start Vagrant VM and check one reply from
    ${result} =  Run Process    vagrant    up  shell=True  stdout=log/vm_start_log.txt
    Should Contain  ${result.stdout}    64 bytes from 192.168.3.2

Ping docker1 from hostvm
    ${result} =  Run Process    vagrant ssh -c 'ping -c3 192.168.1.2'   shell=True  stdout=log/ping_docker1.txt
    Should Contain  ${result.stdout}    64 bytes from 192.168.1.2

Ping docker2 from hostvm
    ${result} =  Run Process    vagrant ssh -c 'ping -c3 192.168.3.2'   shell=True  stdout=log/ping_docker2.txt
    Should Contain  ${result.stdout}    64 bytes from 192.168.3.2

Ping from docker1 to hostvm
    ${result} =  Run Process    vagrant ssh -c 'sudo docker exec docker1 ping -c3 192.168.2.2'   shell=True  stdout=log/ping_from_docker1.txt
    Should Contain  ${result.stdout}    64 bytes from 192.168.2.2

Ping from docker2 to hostvm
    ${result} =  Run Process    vagrant ssh -c 'sudo docker exec docker2 ping -c3 192.168.2.2'   shell=True  stdout=log/ping_from_docker2.txt
    Should Contain  ${result.stdout}    64 bytes from 192.168.2.2

Iperf from hostvm to docker1
    ${result} =  Run Process    vagrant ssh -c 'sudo iperf -c 192.168.1.2'   shell=True  stdout=log/iperf_to_docker1.txt
    Should Contain  ${result.stdout}    connected with 192.168.1.2 port 5001

Iperf from hostvm to docker2
    ${result} =  Run Process    vagrant ssh -c 'sudo iperf -c 192.168.3.2'   shell=True  stdout=log/iperf_to_docker2.txt
    Should Contain  ${result.stdout}    connected with 192.168.3.2 port 5001

Iperf from docker1 to docker2
    ${result} =  Run Process    vagrant ssh -c 'sudo docker exec docker1 iperf -c 192.168.3.2'   shell=True  stdout=log/iperf_docker1_to_docker2.txt
    Should Contain  ${result.stdout}    connected with 192.168.3.2 port 5001

Iperf from docker2 to docker1
    ${result} =  Run Process    vagrant ssh -c 'sudo docker exec docker2 iperf -c 192.168.1.2'   shell=True  stdout=log/iperf_docker2_to_docker1.txt
    Should Contain  ${result.stdout}    connected with 192.168.1.2 port 5001

Iperf from docker1 to hostvm via tap interface
    ${result} =  Run Process    vagrant ssh -c 'sudo docker exec docker1 iperf -c 192.168.2.2'   shell=True  stdout=log/iperf_docker1_to_hostvm_tap.txt
    Should Contain  ${result.stdout}    connected with 192.168.2.2 port 5001

Iperf from docker2 to hostvm via tap interface
    ${result} =  Run Process    vagrant ssh -c 'sudo docker exec docker2 iperf -c 192.168.2.2'   shell=True  stdout=log/iperf_docker2_to_hostvm_tap.txt
    Should Contain  ${result.stdout}    connected with 192.168.2.2 port 5001

Destroy Vagrant VMs and check shutdown message
    ${result} =  Run Process    vagrant destroy -f  shell=True  stdout=log/vm_shutdown_log.txt
    Should Contain  ${result.stdout}    Destroying VM and associated drives...