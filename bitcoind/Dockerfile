FROM debian
RUN apt-get update -y && apt-get upgrade -y && apt-get install apt -y
RUN apt-get install wget sudo vim gpg curl bash -y
RUN wget https://bitcoincore.org/bin/bitcoin-core-0.21.1/bitcoin-0.21.1-x86_64-linux-gnu.tar.gz
RUN wget https://bitcoincore.org/bin/bitcoin-core-0.21.1/SHA256SUMS.asc
RUN tar xzvf bitcoin-0.21.1-x86_64-linux-gnu.tar.gz
RUN cd bitcoin-0.21.1 && ls -al; cp bin/* /bin/;
ENTRYPOINT /bin/bitcoind
