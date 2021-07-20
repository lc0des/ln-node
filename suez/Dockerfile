FROM debian
RUN apt-get update -y && apt-get upgrade -y
RUN apt-get install apt -y
RUN apt install git wget sudo python3 python3-pip -y
RUN pip3 install poetry
WORKDIR /app
RUN git clone https://github.com/prusnak/suez
RUN wget https://github.com/lightningnetwork/lnd/releases/download/v0.12.1-beta/lnd-linux-amd64-v0.12.1-beta.tar.gz
RUN tar xzvf lnd-linux-amd64-v0.12.1-beta.tar.gz --strip-components 1 -C /bin
WORKDIR /app/suez
RUN poetry install
# FIXME
# root@5280301b899e:/app/suez# poetry env list -v
# suez-MqEJMpNd-py3.7 (Activated)
# root@5280301b899e:/app/suez# poetry env list -v --full-path
# /root/.cache/pypoetry/virtualenvs/suez-MqEJMpNd-py3.7 (Activated)
#RUN chown -R 1000:1000 /app
#USER 1000:1000
ENTRYPOINT ["poetry","run","./suez","--client-args=--macaroonpath=/app/lnd/admin.macaroon", "--client-args=--tlscertpath=/app/lnd/tls.cert", "--client-args=--rpcserver=10.21.21.9:10009"]
