#!/bin/bash
MY_HOME="/home/ubuntu"
export DEBIAN_FRONTEND=noninteractive

# Install prereqs
apt update
apt install -y python3-pip apt-transport-https ca-certificates curl software-properties-common

# Install ansible
apt update
apt install -y ansible

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce
usermod -aG docker ubuntu

#### Add PATH ####
printf "\nexport PATH=\$PATH:$MY_HOME/.local/bin\n"  $MY_HOME/.bashrc
exit 0