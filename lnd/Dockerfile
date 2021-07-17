FROM debian
RUN apt-get update -y && apt-get upgrade -y && apt-get install apt -y
RUN apt-get install wget sudo vim gpg curl bash -y
RUN addgroup --gid 1000 lnd
RUN adduser lnd --disabled-password --gecos "Lightning Codes,room77,00492121212121" --gid 1000 --uid 1000 --home /app
WORKDIR /app
RUN mkdir /app/.lnd
COPY lnd.conf /app/.lnd
# Get the 0.12. tagged
RUN wget https://github.com/lightningnetwork/lnd/releases/download/v0.12.1-beta/lnd-linux-amd64-v0.12.1-beta.tar.gz
RUN tar -xf lnd-linux-amd64-v0.12.1-beta.tar.gz --strip-components 1
RUN cp lnd lncli /bin
RUN chown -R 1000:1000 /app
USER 1000:1000
ENTRYPOINT ["/bin/lnd","-C=/app/.lnd/lnd.conf"]
