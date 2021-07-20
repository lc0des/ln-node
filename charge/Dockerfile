FROM python:3-slim

ENV GRPC_LOCATION=172.20.0.3:10009
ENV LND_DIR=~/.lnd/
ENV CONFIG_LOCATION=~/charge.config

ARG USER_ID=1000
ARG GROUP_ID=1000
ENV USER_ID=$USER_ID
ENV GROUP_ID=$GROUP_ID

RUN addgroup --gid $GROUP_ID charge
RUN adduser --home /home/charge --uid $USER_ID --gid $GROUP_ID --disabled-login charge


COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

WORKDIR /home/charge/src
COPY . .

RUN pip install -r requirements.txt .
RUN chown -R charge:charge /home/charge/src

WORKDIR /home/charge
USER charge

RUN mkdir -p /home/charge/.lnd
RUN chown -R $USER_ID:$GROUP_ID /home/charge/.lnd

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]
