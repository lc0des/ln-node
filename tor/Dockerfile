FROM debian
RUN apt-get update -y && apt-get upgrade -y && apt-get install apt
RUN apt-get install wget sudo build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 autoconf -y
RUN apt-get install libevent-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev libboost-thread-dev libzmq3-dev libssl-dev zlib1g zlib1g-dev -y
RUN wget https://github.com/torproject/tor/archive/refs/tags/tor-0.4.6.6.tar.gz
RUN tar xzvf tor-0.4.6.6.tar.gz; cd tor-tor-0.4.6.6/;ls -al;
RUN cd tor-tor-0.4.6.6/;./autogen.sh;./configure --disable-asciidoc && make && make install;
