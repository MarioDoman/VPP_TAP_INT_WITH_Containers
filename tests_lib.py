import os
import subprocess

def ping(address):
    response = os.system("ping -c 4 " + address)
    if response == 0:
        return True
    else:
        return False

def ping_from_docker(docker_addr, ping_addr):
    p = subprocess.run("sudo", "docker", "exec", docker_addr, "ping", "-c3", ping_addr)
