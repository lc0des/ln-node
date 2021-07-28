#!/bin/bash
# It is important that the containers are running, otherwise access to the volumes is not possible like this
#
dc="lcodes"

array=( "th" "rtl" "reb"  )
#echo "${array[1]}" # "first item", again.
#for item in "${array[@]}"; do
#  echo "Iterating over array element $item"
#done

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

function setup_bos_config {
    echo "not implemented yet"
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


#setup_rtl_config
#setup_th_config
#setup_suez_config
#setup_charge_config
setup_rebalance_config
setup_bos_config

# cleanup
rm admin.macaroon lnd.conf tls.cert
