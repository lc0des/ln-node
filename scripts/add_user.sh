#!/bin/bash

username="ln-node"
groupname="ln-node"
userhome="/home/ln-node/"
uid=1000
gid=1000

echo "Adding group: $groupname with id: $gid"
addgroup --gid $gid $groupname
echo "Adding user: $username with id: $uid"
adduser $username --gecos "Bitcoin Core,room77,00492121212121" --gid $gid --uid $uid --home $userhome
adduser $username docker
ls -al $userhome
echo "User creation finished."

#adduser $username --disabled-password --gecos "Bitcoin Core,room77,00492121212121" --gid 1000 --uid 1000 --home /app

