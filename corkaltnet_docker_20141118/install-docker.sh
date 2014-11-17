!/usr/bin/env bash

# See http://docs.docker.com/installation/ubuntulinux/
curl -sSL https://get.docker.com/ubuntu/ | sudo sh

# Add current user to docker group - This is a potential security issue
sudo gpasswd -a ${USER} docker

