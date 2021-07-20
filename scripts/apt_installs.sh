#!/bin/bash
echo "Installing necessary plugins..."
apt-get update -y && apt-get upgrade -y
apt-get install docker wget curl docker.io rsync ufw screen tmux vim netcat strace tcpdump ufw htop git ipython -y
echo "Done."
