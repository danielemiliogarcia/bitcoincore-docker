#!/bin/bash

# If the node do not work in MAC or windows, you might need to change this IP
RPC_ALLOW_IP='0.0.0.0/0'

# The following RPC_AUTH is the encoding for user foo and password rpcpassword
RPC_AUTH='bituser:0ec35794849dcd84089e6c3e6f3ec1c6$e38e8fb1c9753a1ff4ff0020e60976ae1d5f3529c66740f2a09589a733bc20e7'

CONTAINER_NAME="my-bitcoin-testnet3"
IMAGE_NAME="mybitcoinnode:latest"

# Define ports
RPC_PORT=18332
P2P_PORT=18333

# Ensure the network exists
NETWORK_NAME="my-bitcoin-testnet3-network"
docker network ls | grep -q $NETWORK_NAME || docker network create $NETWORK_NAME

echo "Starting Bitcoin Core in Testnet3 mode..."
echo "Container Name: $CONTAINER_NAME"
echo "Joining network: $NETWORK_NAME"
echo "Ports: $RPC_PORT (RPC), $P2P_PORT (P2P)"

# Add the following lsettings to debug
# -debug=1 -debug=rpc -debug=net -debug=mempool -debug=validation

docker run --rm --name $CONTAINER_NAME -it \
  --network=$NETWORK_NAME \
  -p $RPC_PORT:$RPC_PORT \
  -p $P2P_PORT:$P2P_PORT \
  -v $(pwd)/testnet-data:/home/bitcoin/.bitcoin \
  --user $(id -u):$(id -g) \
  $IMAGE_NAME \
  -printtoconsole \
  -testnet=1 \
  -rpcallowip=$RPC_ALLOW_IP \
  -rpcbind=0.0.0.0 \
  -rpcauth=$RPC_AUTH \
  -prune=550
  # -fallbackfee=0.0001 \
  # -minrelaytxfee=0.00001 \
  # -maxtxfee=10000000 \


