import os
import subprocess

def ping(address):
    response = os.system("ping -c 2 " + address)
    if response == 0:
        return True
    else:
        return False

def ping_from_docker(docker_addr, ping_addr, file):
    with open(file, "a") as output:
        subprocess.call(f"sudo docker exec {docker_addr} ping {ping_addr} -c2", shell=True, stdout=output, stderr=output)
    with open(file) as f:
        if f"64 bytes from {ping_addr}" in f.read():
            return True

def iperf_from_host(docker_ip, file):
    with open(file, "a") as output:
        subprocess.call(f"sudo iperf -c {docker_ip}", shell=True, stdout=output, stderr=output)
    with open(file) as f:
        if f"connected with {docker_ip} port 5001" in f.read():
            return True

def iperf_between_dockers(source_docker, dest_docker_ip, file):
    with open(file, "a") as output:
        subprocess.call(f"sudo docker exec {source_docker} iperf -c {dest_docker_ip}", shell=True, stdout=output, stderr=output)
    with open(file) as f:
        if f"connected with {dest_docker_ip} port 5001" in f.read():
            return True

        
    

