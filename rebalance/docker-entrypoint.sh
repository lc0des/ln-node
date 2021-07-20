#!/usr/bin/env sh

exec /app/rebalance-lnd/rebalance.py --grpc "${GRPC_LOCATION}" --lnddir "${LND_DIR}" "$@"
