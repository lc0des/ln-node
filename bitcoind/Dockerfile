FROM debian
RUN apt-get update -y && apt-get upgrade -y && apt-get install apt -y
RUN apt-get install wget sudo vim gpg curl bash -y
RUN addgroup --gid 1000 btcore
RUN adduser btcore --disabled-password --gecos "Bitcoin Core,room77,00492121212121" --gid 1000 --uid 1000 --home /app
WORKDIR /app
RUN mkdir /app/.bitcoin
COPY bitcoin.conf /app/.bitcoin
# Get the latest bitcoin daemon 17.07.2021
RUN wget https://bitcoincore.org/bin/bitcoin-core-0.21.1/bitcoin-0.21.1-x86_64-linux-gnu.tar.gz
RUN wget https://bitcoincore.org/bin/bitcoin-core-0.21.1/SHA256SUMS.asc
RUN echo `cat SHA256SUMS.asc |grep bitcoin-0.21.1-x86_64-linux-gnu.tar.gz`|sha256sum -c;
RUN tar xzvf bitcoin-0.21.1-x86_64-linux-gnu.tar.gz
RUN cd bitcoin-0.21.1 && ls -al; cp bin/* /bin/;cd ..;rm -fr bitcoin*;rm -fr SHA256SUMS.asc
RUN chown -R 1000:1000 /app
USER 1000:1000
ENTRYPOINT ["/bin/bitcoind","-datadir=/app/.bitcoin"]
