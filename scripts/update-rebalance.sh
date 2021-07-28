#!/bin/bash
#set -x
dc="lcodes"
rebalance_ip="172.20.0.22"
userhome="/home/ln-node"
repository="ln-node"
logs_home="$workdir/logs/"
DESCLOG="$logs_home/setup.log"
workdir="$userhome/$repository/data"
rebalance_home="$workdir/rebalance/"
dchost="ln-node"
lnd_ip="172.20.0.3"
lnd_grpc=10009
uid=1000
gid=1000
repodir="$userhome/$repository/"
tag=""

# rebalance-lnd
function show_tags {
    mkdir -p $rebalance_home
    cd $rebalance_home/rebalance-lnd
    # first we pull all new data
    git pull
    # now we show all available tags
    git tag
}

function update_reblnd {
    mkdir -p $rebalance_home
    cd $rebalance_home/rebalance-lnd
    # first we pull all new data
    git pull
    # now we show all available tags
    git tag
    #git clone https://github.com/C-Otto/rebalance-lnd -b $tag && cd rebalance-lnd
    cp $repodir/rebalance/Dockerfile .
    cp $repodir/rebalance/docker-entrypoint.sh .
    docker build . -t $dc-reblnd
#    docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$rebalance_home --opt o=bind $dc-vol-reblnd
    docker run -it --rm --network="$dc-net" --add-host=$dchost:$lnd_ip --ip=$rebalance_ip -v $dc-vol-reblnd:/app $dc-reblnd --grpc $lnd_ip:$lnd_grpc --lnddir /app/lnd/ -h
}

function usage {
echo "Script for updating rebalance-lnd"
echo "$0 <command>"
echo "-t show tags"
echo "-u update"
echo
exit
}

if [ $# -lt 1 ];then
    usage
    exit
fi
optstring="tu:h"
while getopts ${optstring} arg; do
 case ${arg} in
   u)
	if [ $# -ne 2 ];then
	echo "Please give argument for tag"
	echo "Example:"
	echo "$0 -u v2.0"
	exit
	fi
	tag=$2
	update_reblnd $tag
	
   ;;
   t)
	show_tags
   ;;
   h)
    usage
    exit
   ;;
esac
done

