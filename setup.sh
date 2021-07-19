#!/bin/bash
set -x
userhome="/home/ln-node"
repository="ln-node"
dc="lcodes"
workdir="$userhome/$repository/data"
repodir="$userhome/$repository/"
dockergw="172.20.0.1"
dockeripr="172.20.0.0/16"
dockersub="172.20.0.0/24"
bitcoind_ip="172.20.0.2"
lnd_ip="172.20.0.3"
tor_ip="172.20.0.5"
th_ip="172.20.0.10"
rtl_ip="172.20.0.11"
uid=1000
gid=1000
bitcoind_home="$workdir/bitcoin/"
lnd_home="$workdir/lnd/"
rtl_home="$workdir/rtl/"
th_home="$workdir/th/"
tor_home="$workdir/tor/"
logs_home="$workdir/logs/"
DESCLOG="$logs_home/setup.log"

function usage {
echo 'Wrapper Script for lcodes Lightning Node Server Setup'
echo '	-T build Tor'
echo '	-t build thunderhub'
echo '	-r build rtl'
echo '	-b build bitcoind'
echo '	-l build lnd'
echo '	-a build all'
echo '	-h help'

}


if [ $# -lt 1 ];then
	usage
	exit
fi

function setup_daemon_config {
	cd $workdir/
	gen_user=`cat /dev/urandom | xxd -l 23 -p -u -c 23|sed -r 's/\s+//g'`
	gen_pass=`cat /dev/urandom | xxd -l 42 -p -u -c 42|sed -r 's/\s+//g'`
	#rpc_entry=`python3 ../tools/rpcauth.py lnnode $gen_pass|grep rpcauth|cut -d '=' -f2`
	rpc_entry=`python3 ../tools/rpcauth.py $gen_user $gen_pass|grep rpcauth|cut -d '=' -f2`
	sed -i "s/REPLACEME_RPCAUTH/$rpc_entry/" ../bitcoind/bitcoin.conf

	lnd_user=`echo $rpc_entry|cut -d ':' -f1`
	lnd_pass=$gen_pass
	#sed -i "s/REPLACEME_RPCUSER_LND/lnnode/" ../lnd/lnd.conf
	sed -i "s/REPLACEME_RPCUSER_LND/$lnd_user/" ../lnd/lnd.conf
	sed -i "s/REPLACEME_RPCPASSWORD_LND/$lnd_pass/" ../lnd/lnd.conf

}


function setup_lnd_password {
	echo "Creating LND Wallet, please enter Passphrase"
	docker exec -ti lcodes-lnd lncli create
	docker exec -ti lcodes-lnd lncli unlock
}

function prepare_system {
# Check if we have all packets ready
#apt-get update -y && apt-get upgrade -y
#apt-get install git wget curl screen tmux docker docker.io htop -y

# create my new home
mkdir -p $workdir
mkdir -p $logs_home
}

# Building the network bridge  ############################
###########################################################
function build_bridge {
# Build up the docker network
docker network create -d bridge --gateway $dockergw --ip-range $dockeripr --subnet $dockersub $dc-net
}

# Lightning Network Daemon  ###############################
#							  #
# Create the lnd container			     	  #
#							  #
###########################################################
function build_bitcoind {
# Create the bitcoind docker
echo "Building new bitcoin core docker..."

# create new bitcoin daemon home
mkdir -p $bitcoind_home
cd $repodir
cd bitcoind/

#docker build -t $dc-bitcoind - < bitcoind/Dockerfile
docker build . -t $dc-bitcoind
cd ..

# bitcoind volume
echo "Building docker volume for bitcoind..."
docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$bitcoind_home --opt o=bind $dc-vol-bitcoind

# removed  flag for restart always
docker run -d  --restart=always -u=$uid:$gid --name=$dc-bitcoind --net=$dc-net -p 8333:8333 -p 127.0.0.1:8332:8332 --ip=$bitcoind_ip -v $dc-vol-bitcoind:/app/.bitcoin -u$uid:$gid $dc-bitcoind

}

# Lightning Network Daemon  ###############################
#							  #
# Create the lnd container			     	  #
#							  #
###########################################################
function build_lnd {

# Create the lnd docker
echo "Lets build our magic lnd docker...."
mkdir -p $lnd_home
cd $repodir
cd lnd/
docker build . -t $dc-lnd
docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$lnd_home --opt o=bind $dc-vol-lnd

# removed  flag for restart always
docker run  -d --restart=always --net=lcodes-net --ip=$lnd_ip -p 9735:9735 -p9911:9911 -p 127.0.0.1:8080:8080 -p 127.0.0.1:10009:10009 --name $dc-lnd -v $dc-vol-lnd:/app/.lnd $dc-lnd
cd ..

}

# Ride the Lightning  #####################################
#							  #
# Create the rtl container			     	  #
#							  #
###########################################################
function build_rtl {
# Create the RTL Container
echo "Lets build the Ride the Lightning App Container ..."
mkdir -p $rtl_home
cd $repodir
git clone https://github.com/Ride-The-Lightning/RTL -b v0.11.0
cd rtl
cp Dockerfile RTL-Config.json ../RTL/
cd ../RTL
docker build . -t lcodes-rtl
docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$rtl_home --opt o=bind $dc-vol-rtl
docker run -d  --name=$dc-rtl --restart=always -p 127.0.0.1:3001:3001 --net=$dc-net --ip=$rtl_ip $dc-rtl
cd ..
}

# Thunderhub ##############################################
#							  #
# Create the thunderhub container			  #
#							  #
###########################################################
function build_th {

# Create the Thunderhub home
mkdir -p $th_home
cd $repodir

# get data from github
git clone https://github.com/apotdevin/thunderhub -b v0.12.21

# enter directory
cd thunderhub

# build container
docker build . -t lcodes-th

# setup volume
docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$th_home --opt o=bind $dc-vol-th

# run the container
docker run  -d --restart=always --name=$dc-th --net=$dc-net --ip=$th_ip -p 127.0.0.1:3000:3000/tcp -v $dc-vol-th:/app/data/ $dc-th
cd ..
}

# TOR #####################################################
#							  #
# Create the good old TOR container ... yeaaaahhh	  #
#							  #
###########################################################
function build_tor {
	
	# create new tor daemon home
	mkdir -p $tor_home
	cd $repodir

	# lets move into the directory
	cd tor

	# build the docker image
	docker build . -t $dc-tor

	# setup the volume
	docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$tor_home --opt o=bind $dc-vol-tor



	# start container
	docker run  -d --restart=always --net=$dc-net --ip=$tor_ip -v $dc-vol-tor:/app/data/ --name $dc-tor $dc-tor
	echo "Waiting for $dc-tor to come up"
	sleep 30

	# create TOR hashed password
	gen_pass=`cat /dev/urandom | xxd -l 23 -p -u -c 23|sed -r 's/\s+//g'`
	gen_torhash=`docker exec lcodes-tor tor --hash-password $gen_pass`
	# set TOR hashed password in torrc 
	sed -i "s/881A8D4F1E9FB2D3C8A25CE1317B111BB162B273F40FE9/$gen_torhash/" ../tor/torrc
	#sed -i "s/REPLACEME_TORHASHEDPASSWORD/$gen_torhash/" ../tor/torrc
	sleep 5

	# copying new torrc over 
	docker cp ../tor/torrc $dc-tor:/app/torrc

	# restarting the container 
	docker restart lcodes-tor

	# set TOR password in LND conf
	sed -i "s/REPLACEME_TORPASSWORD/$gen_pass/" ../lnd/lnd.conf
	sleep 5

	tor_bitcoind=`docker exec -ti lcodes-tor cat /app/data/lcodes-bitcoind/hostname`
	tor_lnd=`docker exec -ti lcodes-tor cat /app/data/lcodes-lnd/hostname`
	echo "Bitcoin Onion Addr: $tor_bitcoind" >> $DESCLOG
	echo "LND Onion Addr: $tor_bitcoind" >> $DESCLOG

	# subsitate placeholde with ONION Address
	sed -i "s/REPLACEME_ONION_ADDR/$tor_bitcoind/" ../bitcoind/bitcoin.conf

	# leaving directory
	cd ..
}

# basic checks if all has worked
function check_run() {
docker ps
ss -antpl
}

prepare_system

optstring=":hTtrbla"
while getopts ${optstring} arg; do
 case ${arg} in
   T)
	build_tor
   ;;
   t)
	build_th
   ;;
   r)
	build_rtl
   ;;
   b)
	build_bitcoind
   ;;
   l)
	build_lnd
   ;;
   a)
    setup_daemon_config
	build_bridge
   	build_tor
	build_bitcoind
	build_lnd
	build_rtl
	build_th
	setup_lnd_password
   ;;
   h)
	usage
	echo 'help'
        exit
   ;;

   :)   echo 'ehlp'
	usage
	exit
;;
esac
done
