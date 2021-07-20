FROM python:3-slim

ENV GRPC_LOCATION=172.20.0.3:10009
ENV LND_DIR=/app/lnd

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

WORKDIR /app/

COPY requirements.txt .

RUN pip install -r requirements.txt

COPY . .

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]

