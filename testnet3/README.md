# Bitcoin testnet3 docker container

## Run (You should build the container 1st)
```
./lauch-testnet-node.sh
```

## Run with compose
```
docker-compose up
```

## RPC password
Generated via:
```
-> $ curl -sSL https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py | python - bituser bitpass
```

String to be appended to bitcoin.conf:
```
rpcauth=bituser:0ec35794849dcd84089e6c3e6f3ec1c6$e38e8fb1c9753a1ff4ff0020e60976ae1d5f3529c66740f2a09589a733bc20e7
```

Your password:
```
bitpass
```

Your user:
```
bituser
```

## RPC example

CURL
```
curl -d '{"jsonrpc":"1.0","id":"1","method":"getnetworkinfo","params":[]}' http://bituser:bitpass@127.0.0.1:18332 | jq
```

Bitcoin CLI from other host

```
docker run -it --network=my-bitcoin-testnet3-network --rm mybitcoinnode:latest \
  bitcoin-cli \
  -rpcconnect=my-bitcoin-testnet3 \
  -testnet \
  -rpcuser=bituser\
  -rpcpassword="bitpass" \
  getnetworkinfo
```

## Short Alias to use bitcoin-cli from the same container
```
alias btc="docker exec my-bitcoin-testnet3 bitcoin-cli -testnet -rpcuser=bituser -rpcpassword=bitpass"
```
Then
```
btc getnetworkinfo
```

## Ports

Testnet3 JSON-RPC: 18332
Testnet3 P2P: 18333

## MEMPOOL (you should remove prune and add -txindex to use it)

Run
```
docker-compose -f docker-compose-mempool.yml up
```

Browse http://localhost:1081/