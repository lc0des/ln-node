#!/bin/bash
set -x

userhome="/home/ln-node"
repository="ln-node"
dc="lcodes"
dchost="ln-node"
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
bos_ip="172.20.0.20"
charge_ip="172.20.0.21"
rebalance_ip="172.20.0.22"
suez_ip="172.20.0.23"
uid=1000
gid=1000
bitcoind_home="$workdir/bitcoin/"
lnd_home="$workdir/lnd/"
rtl_home="$workdir/rtl/"
th_home="$workdir/th/"
tor_home="$workdir/tor/"
bos_home="$workdir/bos/"
suez_home="$workdir/suez/"
charge_home="$workdir/charge/"
rebalance_home="$workdir/rebalance/"
logs_home="$workdir/logs/"
DESCLOG="$logs_home/setup.log"

function usage {
echo 'Wrapper Script for lcodes Lightning Node Server Setup'
echo '	-T build Tor'
echo '	-t build thunderhub'
echo '	-r build rtl'
echo '	-b build bitcoind'
echo '	-l build lnd'
echo '	-s build suez'
echo '	-c build charge'
echo '	-R build rebalance-lnd'
echo '	-b build bos'
echo '	-a build all'
echo '	-h help'
}


if [ $# -lt 1 ];then
	usage
	exit
fi

function setup_bash_alias {
	cd $repodir
	cat supply/lcodes_bashrc >> $userhome/.bashrc
	. $userhome/.bashrc
}

function setup_daemon_config {

	# setup for bitcoind
	echo "Generating random passwords for bitcoind..."
	cd $workdir/
	gen_user=`cat /dev/urandom | xxd -l 23 -p -u -c 23|sed -r 's/\s+//g'`
	gen_pass=`cat /dev/urandom | xxd -l 42 -p -u -c 42|sed -r 's/\s+//g'`
	#rpc_entry=`python3 ../tools/rpcauth.py lnnode $gen_pass|grep rpcauth|cut -d '=' -f2`
	rpc_entry=`python3 ../tools/rpcauth.py $gen_user $gen_pass|grep rpcauth|cut -d '=' -f2`
	echo "Adding hashed password with user to bitcoin.conf"
	sed -i "s/REPLACEME_RPCAUTH/$rpc_entry/" ../bitcoind/bitcoin.conf
	echo "Bitcoind RPC User: $gen_user" >> $DESCLOG
	echo "Bitcoind RPC Password: $gen_pass" >> $DESCLOG
	echo "Bitcoind RPCAUTH: $rpc_entry" >> $DESCLOG

	# setup for lnd
	lnd_user=`echo $rpc_entry|cut -d ':' -f1`
	lnd_pass=$gen_pass
	echo "Adding password and user to lnd.conf"
	sed -i "s/REPLACEME_RPCUSER_LND/$lnd_user/" ../lnd/lnd.conf
	sed -i "s/REPLACEME_RPCPASSWORD_LND/$lnd_pass/" ../lnd/lnd.conf

	# setup for rtl
	echo "Adding random password to rtl conf (RTL-Config.json)"
	gen_pass=`cat /dev/urandom | xxd -l 23 -p -u -c 23|sed -r 's/\s+//g'`
	sed -i "s/REPLACEME_RTLPASSWORD/$gen_pass/" ../rtl/RTL-Config.json
	echo "RTL Password: $gen_pass" >> $DESCLOG

	# setup for th
	echo "Adding random password to th conf (th.yaml)"
	gen_pass=`cat /dev/urandom | xxd -l 23 -p -u -c 23|sed -r 's/\s+//g'`
	sed -i "s/REPLACEME_THPASSWORD/$gen_pass/" ../th/th.yaml
	echo "TH Password: $gen_pass" >> $DESCLOG
}

function setup_bos_config {
	echo "not implemented yet"
}
function setup_rebalance_config {
	mac="admin.macaroon"
	lnd="lnd.conf"
	cert="tls.cert"
	cntr="$dc-reblnd"
	docker_vol_path="/app/lnd/"
	echo "Copying $mac and $cert to $dc-vol-reblnd $docker_vol_path"
	ret=`docker run -d --rm --entrypoint="" -v $dc-vol-reblnd:/app $cntr sleep 3600`
	docker exec -u $uid:$gid $ret mkdir -p $docker_vol_path
	docker exec -u $uid:$gid $ret mkdir -p $docker_vol_path/data/chain/bitcoin/mainnet/
	docker cp $dc-lnd:/app/.lnd/$lnd .
	docker cp $dc-lnd:/app/.lnd/data/chain/bitcoin/mainnet/$mac .
	docker cp $dc-lnd:/app/.lnd/$cert .
	docker cp $lnd $ret:$docker_vol_path
	docker cp $mac $ret:$docker_vol_path/data/chain/bitcoin/mainnet/
	docker cp $cert $ret:$docker_vol_path
	docker stop $ret
}
function setup_charge_config {
	mac="admin.macaroon"
	lnd="lnd.conf"
	cert="tls.cert"
	cntr="$dc-charge"
	docker_vol_path="/home/charge/.lnd/"
	echo "Copying $mac and $cert to $dc-vol-charge $docker_vol_path"
	ret=`docker run -d --rm --entrypoint="" -v $dc-vol-charge:/home/charge/ $cntr sleep 3600`
	docker exec -u $uid:$gid $ret mkdir -p $docker_vol_path
	docker exec -u $uid:$gid $ret mkdir -p $docker_vol_path/data/chain/bitcoin/mainnet/
	docker cp $dc-lnd:/app/.lnd/$lnd .
	docker cp $dc-lnd:/app/.lnd/data/chain/bitcoin/mainnet/$mac .
	docker cp $dc-lnd:/app/.lnd/$cert .
	docker cp $lnd $ret:$docker_vol_path
	docker cp $mac $ret:$docker_vol_path/data/chain/bitcoin/mainnet/
	docker cp $cert $ret:$docker_vol_path
	docker stop $ret
}

function setup_suez_config {
	mac="admin.macaroon"
	lnd="lnd.conf"
	cert="tls.cert"
	cntr="$dc-suez"
	docker_vol_path="/app/lnd/"
	echo "Copying $mac and $cert to $dc-vol-suez $docker_vol_path"
	ret=`docker run -d --rm --entrypoint="" -v $dc-vol-suez:/app $cntr sleep 600`
	docker exec -u $uid:$gid $ret mkdir $docker_vol_path
	#docker exec -u $uid:$gid $dc-suez mkdir $docker_vol_path
	docker cp $dc-lnd:/app/.lnd/$lnd .
	docker cp $dc-lnd:/app/.lnd/data/chain/bitcoin/mainnet/$mac .
	docker cp $dc-lnd:/app/.lnd/$cert .
	docker cp $lnd $ret:$docker_vol_path
	docker cp $mac $ret:$docker_vol_path
	docker cp $cert $ret:$docker_vol_path
	docker stop $ret
}

function setup_th_config {
	mac="admin.macaroon"
	lnd="lnd.conf"
	cert="tls.cert"
	th_docker_path="/app/data/lnd/"
	th_yaml_path="/app/data/th.yaml"
	th_yaml_dpath="/app/data/th.yaml"
	echo "Copying $mac and $lnd to $dc-vol-th $th_docker_path"
	docker exec -u $uid:$gid $dc-th mkdir $th_docker_path
	docker cp $dc-lnd:/app/.lnd/$lnd .
	docker cp $dc-lnd:/app/.lnd/data/chain/bitcoin/mainnet/$mac .
	docker cp $dc-lnd:/app/.lnd/$cert .
	docker cp $lnd $dc-th:$th_docker_path
	docker cp $mac $dc-th:$th_docker_path
	docker cp $cert $dc-th:$th_docker_path
	docker cp $repodir/th/th.yaml $dc-th:$th_yaml_dpath
	docker restart $dc-th
}

function setup_rtl_config {
	mac="admin.macaroon"
	lnd="lnd.conf"
	rtl_docker_path="/data/lnd/"
	echo "Copying $mac and $lnd to $dc-vol-rtl $rtl_docker_path"
	docker cp $dc-lnd:/app/.lnd/$lnd .
	docker cp $dc-lnd:/app/.lnd/data/chain/bitcoin/mainnet/$mac .
	docker cp $lnd $dc-rtl:/data/lnd/
	docker cp $mac $dc-rtl:/data/lnd/
	docker restart $dc-rtl
}

function setup_lnd_wallet {
	echo "Creating LND Wallet, please enter Passphrase"
	docker exec -ti $dc-lnd lncli create
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



# Bitcoin Daemon  #########################################
#							  							  #
# Create the bitcoin container			     	  		  #
#							     						  #
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
#							  							  #
# Create the lnd container			     	  			  #
#							  							  #
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
docker run  -d --restart=always --net=$dc-net --ip=$lnd_ip -p 9735:9735 -p9911:9911 -p 127.0.0.1:8080:8080 -p 127.0.0.1:10009:10009 --name $dc-lnd -v $dc-vol-lnd:/app/.lnd $dc-lnd
cd ..

}



# Ride the Lightning  #####################################
#							  							  #
# Create the rtl container			     	  			  #
#							  							  #
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
	
	docker build . -t $dc-rtl
	
	docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$rtl_home --opt o=bind $dc-vol-rtl
	
	docker run -d  --name=$dc-rtl --restart=always -p 127.0.0.1:3001:3001 --net=$dc-net --ip=$rtl_ip $dc-rtl
	
	cd ..
}

# Thunderhub ##############################################
#							  							  #
# Create the thunderhub container			  			  #
#							  							  #
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
docker build . -t $dc-th

# setup volume
docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$th_home --opt o=bind $dc-vol-th

# run the container
docker run  -d --restart=always --name=$dc-th --net=$dc-net --ip=$th_ip -p 127.0.0.1:3000:3000/tcp -v $dc-vol-th:/app/data/ --add-host=$dchost:172.20.0.3 --env NO_VERSION_CHECK="true" --env LOG_LEVEL="debug" --env ACCOUNT_CONFIG_PATH="/app/data/th.yaml" $dc-th
cd ..
}

# TOR #####################################################
#							  							  #
# Create the good old TOR container ... yeaaaahhh	      #
#							    						  #
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
	sleep 10

	# create TOR hashed password
	gen_pass=`cat /dev/urandom | xxd -l 23 -p -u -c 23|sed -r 's/\s+//g'`
	gen_torhash=`docker exec $dc-tor tor --hash-password $gen_pass`
	# set TOR hashed password in torrc 
	sed -i "s/16:3395E2777E2DFC5560DDAB07C1717D261E7D3B5D29827EAAF109B33290/$gen_torhash/" ../tor/torrc
	#sed -i "s/REPLACEME_TORHASHEDPASSWORD/$gen_torhash/" ../tor/torrc
	sleep 1 

	# copying new torrc over 
	docker cp ../tor/torrc $dc-tor:/app/torrc

	# restarting the container 
	docker restart $dc-tor

	# set TOR password in LND conf
	sed -i "s/REPLACEME_TORPASSWORD/$gen_pass/" ../lnd/lnd.conf
	echo "TOR Control Password: $gen_pass" >> $DESCLOG
	sleep 1

	tor_bitcoind=`docker exec -ti $dc-tor cat /app/data/lcodes-bitcoind/hostname`
	tor_lnd=`docker exec -ti $dc-tor cat /app/data/lcodes-lnd/hostname`
	echo "Bitcoin Onion Addr: $tor_bitcoind" >> $DESCLOG
	echo "LND Onion Addr: $tor_lnd" >> $DESCLOG

	# subsitate placeholde with ONION Address
	sed -i "s/REPLACEME_ONION_ADDR/$tor_bitcoind/" ../bitcoind/bitcoin.conf

	# leaving directory
	cd ..
}

# BOS 

function build_bos {
	mkdir -p $bos_home
	cd $bos_home
#	git https://github.com/alexbosworth/balanceofsatoshis
#	cd balanceofsatoshis
	echo "Pulling BOS from dockerhub..."
	mkdir $userhome/.bos
	docker pull alexbosworth/balanceofsatoshis
	echo "Check output for errors ...."
	docker run -it --rm -v $HOME/.bos:/home/node/.bos alexbosworth/balanceofsatoshis --version
	sleep 1 
	echo "This must show correct reporting..."
	docker run -it --rm --network="$dc-net" --add-host=$dchost:$lnd_ip -v $userhome/.bos:/home/node/.bos -v $workdir/lnd:/home/node/.lnd:ro alexbosworth/balanceofsatoshis report
	sleep 1
}

# suez
function build_suez {
	mkdir -p $suez_home
	cd $suez_home
	git clone https://github.com/prusnak/suez && cd suez
	cp $repodir/suez/Dockerfile .
	docker build . -t $dc-suez
	docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$suez_home --opt o=bind $dc-vol-suez
	docker run -it --rm --network="$dc-net" --add-host=$dchost:$lnd_ip --ip=$suez_ip -v $dc-vol-suez:/app $dc-suez --help
	sleep 1
}

# charge-lnd
function build_charge {
	mkdir -p $charge_home
	cd $charge_home
	git clone https://github.com/accumulator/charge-lnd && cd charge-lnd
	cp $repodir/charge/Dockerfile .
	docker build . -t $dc-charge
	docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$charge_home --opt o=bind $dc-vol-charge
	docker run -it --rm --network="$dc-net" --add-host=$dchost:$lnd_ip --ip=$charge_ip -v $dc-vol-charge:/app $dc-charge -h
	sleep 1
}

# rebalance-lnd
function build_reblnd {
	mkdir -p $rebalance_home
	cd $rebalance_home
	git clone https://github.com/C-Otto/rebalance-lnd && cd rebalance-lnd
	cp $repodir/rebalance/Dockerfile .
	cp $repodir/rebalance/docker-entrypoint.sh .
	docker build . -t $dc-reblnd
	docker volume create --driver local --opt o=uid=$uid,gid=$uid --opt device=$rebalance_home --opt o=bind $dc-vol-reblnd
	docker run -it --rm --network="$dc-net" --add-host=$dchost:$lnd_ip --ip=$rebalance_ip -v $dc-vol-reblnd:/lnd:ro $dc-reblnd -h
	sleep 1
}

# basic checks if all has worked
function check_run() {
docker ps
ss -antpl
}

prepare_system

optstring=":hTtrblascRb"
while getopts ${optstring} arg; do
 case ${arg} in
   s) 
    build_suez
	setup_suez_config
   ;;
   c)
    build_charge
	setup_charge_config
   ;;
   R)
    build_reblnd
	setup_reblnd_config
   ;;
   b)
    build_bos
   ;;
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
	setup_lnd_wallet
	setup_rtl_config
	setup_th_config
	setup_bash_alias

	build_bos
	build_reblnd
	build_charge
	build_suez

	setup_suez_config
	setup_charge_config
	setup_rebalance_config
	setup_bos_config

   ;;
   h)
	usage
	echo 'help'
        exit
   ;;

   :)   echo 'help'
	usage
	exit
;;
esac
done
