# ln-node

## What is the difference to others
LN-Node is my implementation for setting up a Lightning Network Node quickly on a Debian/Ubuntu System. The goal is to keep it as light as possible but also useable out of the box.This means that Tools like Thunderhub or Ride The Lightning are onboard, but nothing more.

## Target Audience
This package is **NOT** for Unix/Linux starters. Probably also not for beginners with BTC/LN. Things can go terribly wrong - You have been warned. 

For everyone else, you have a nice little script plus files here to quickly setup an environment and adjust it to your liking.

## Anonymity
This package is *not* designed for anonymity through the Tor Network. Tor is used
for being able to communicate with Tor LN nodes as well as supporting the P2P connections of bitcoind and lnd in Tor.

## Features

* Out of the Box Bitcoind and LND
* All dockerized and running in an own network
* Support of Tor
* Support of Thunderhub
* Support of Ride the Lightning

## Version
Version 0.1-Alpha


## Usage
```
git clone https://github.com/lc0des/ln-node
cd ln-node
./setup.sh -a
```

## Done

* build fresh container for bitcoind, lnd, th, rtl, tor
* build volumes for each container
* rnd user and password configuration for bitcoind and wire them to bitcoind/lnd
* rnd hash for tor, plus automatic wire during setup time
* sensitive services only accessable by localhost
* wire bitcoind with tor (support for clearnet AND tor network)
* wire lnd with tor
* wallet creation at runtime

## Todo

* wire RTL with ln-node
* wire Thunderhub with ln-node

## Disclaimer
Run at your own RISK! I do not take any responsibility for you loosing any funds or alike. This software is provided AS-IS.
