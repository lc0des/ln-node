# ⚠ ONLY USE ON TESTNODES SOME PARAMETERS ARE STILL HARDCODED ⚠

# ⚡ ln-node ⚡

## What is the difference to others
LN-Node is my implementation for setting up a Lightning Network Node quickly on a Debian/Ubuntu System. The goal is to keep it as light as possible but also useable out of the box as a router node.
This means i will not add any extra fancy web-interface or alike. However, some tools like:
* [Thunderhub](https://github.com/apotdevin/thunderhub) 
* [Ride The Lightning](https://github.com/Ride-The-Lightning/RTL)
* [Balance of Satoshi](https://github.com/alexbosworth/balanceofsatoshis)
* [rebalance-lnd](https://github.com/C-Otto/rebalance-lnd)
* [charge-lnd](https://github.com/accumulator/charge-lnd)
* [suez](https://github.com/prusnak/suez)
are onboarded as i do consider them very helpful for the daily business of a node operator.

## Target Audience
This package is **NOT** for Unix/Linux starters. Probably also not for beginners with BTC/LN. Things can go terribly wrong.You have been warned. 

For everyone else:   
You have a nice little script plus files here to quickly setup an environment and adjust it to your liking.

## Anonymity
This package is *not* designed for anonymity through the Tor Network. Tor is used
for being able to communicate with Tor LN nodes as well as supporting the P2P connections of bitcoind and lnd in Tor.

## Features

* Out of the Box Bitcoind and LND
* Supports Tor
* Supports Thunderhub
* Supports Ride the Lightning
* Supports BOS
* Supports Rebalance-LND
* Supports Charge-LND
* Supports Suez
* Management Services **ONLY** accessable through localhost
* All dockerized and running their an own network

## Version
* Version 0.2.3-Alpha

### Tested
* Debian 10.10 - Working


## Usage

### Installation
```
git clone https://github.com/lc0des/ln-node
cd ln-node
./install.sh -a
```

## Wallets

### Bitcoind 

During setup *no* wallet is created, you have to do this for yourself.

### LND

During setup a wallet *is* created, the password has to be choosen manually, you can also add a known seed.

## Passwords

For the following services the passwords are randomly generated during setup time:  
* Bitcoind RPC
* LND Macaroons (automatically after wallet creation)
* Tor
* Ride the Lightning
* Thunderhub

A **cleartext** password **file** is created at `ln-node/data/logs/setup.log` for 
getting access to services like RTL. Please make sure that you will **erase** the 
file after **storing** the passwords in a **secure** area.

For this you can use wipe:
```
$ wipe ln-node/data/logs/setup.log
```

Or shred:
```
$ shred -n 23 -uvz ln-node/data/logs/setup.log
```

## Done ✅ 

* build fresh container for bitcoind, lnd, th, rtl, tor
* build volumes for each container
* rnd user and password configuration for bitcoind and wire them to bitcoind/lnd
* rnd hash for tor, plus automatic wire during setup time
* sensitive services only accessable by localhost
* wire bitcoind with tor (support for clearnet AND tor network)
* wire lnd with tor
* wallet creation at runtime
* wire RTL with ln-node
* random password rtl
* wire Thunderhub with ln-node
* random password thunderhub
* added BOS
* added Rebalance-LND
* added charge-lnd
* added suez

## Todo 🚧

* add flag for password on screen output only 
* configuration for tor only (no clearnet)
* docker hardening
* service hardening
* server hardening links
* config file for pre-install phase
* several flags for custom prefs
* take care of changing certs/macaroons if lnd is restarted/reconfigured

## ⚠ Disclaimer ⚠

Run at your own RISK!  

I do not take any responsibility for you loosing any funds or alike. This software is provided AS-IS.
