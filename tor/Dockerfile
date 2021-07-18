FROM debian
RUN apt-get update -y && apt-get upgrade -y && apt-get install apt
RUN apt-get install wget sudo build-essential libtool autotools-dev automake pkg-config bsdmainutils python3 autoconf -y
RUN apt-get install libevent-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev libboost-thread-dev libzmq3-dev libssl-dev zlib1g zlib1g-dev -y
RUN wget https://github.com/torproject/tor/archive/refs/tags/tor-0.4.6.6.tar.gz
RUN tar xzvf tor-0.4.6.6.tar.gz; cd tor-tor-0.4.6.6/;ls -al;
RUN cd tor-tor-0.4.6.6/;./autogen.sh;./configure --disable-asciidoc && make && make install;
RUN addgroup --gid 1000 tor
RUN adduser tor --disabled-password --gecos "Tor Network User, 1337" --gid 1000 --uid 1000 --home /app
WORKDIR /app
RUN mkdir /app/data/
COPY torrc /app/
RUN mkdir /app/data/lcodes-bitcoind/
RUN mkdir /app/data/lcodes-lnd/
RUN chown -R 1000:1000 /app
RUN chmod -R 0700 /app
USER 1000:1000
ENTRYPOINT ["tor","-f","/app/torrc"]
