# Bitcoin regtest docker container

## Run (You should build the container 1st)
```
./lauch-regtest-node.sh
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
curl -d '{"jsonrpc":"1.0","id":"1","method":"getnetworkinfo","params":[]}' http://bituser:bitpass@127.0.0.1:18443 | jq
```

Bitcoin CLI from other host

```
docker run -it --network=my-bitcoin-regtest-network --rm mybitcoinnode:latest \
  bitcoin-cli \
  -rpcconnect=my-bitcoin-regtest \
  -regtest \
  -rpcuser=bituser\
  -rpcpassword="bitpass" \
  getnetworkinfo
```

## Short Alias to use bitcoin-cli from the same container
```
alias btc="docker exec my-bitcoin-regtest bitcoin-cli -regtest -rpcuser=bituser -rpcpassword=bitpass"
```
Then
```
btc getnetworkinfo
```

example to generate 3 blocks
```
btc generatetoaddress 3 "bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y"
```

## Ports

Regtest JSON-RPC: 18443
Regtest P2P: 18444

## MEMPOOL

Run
```
docker-compose -f docker-compose-mempool.yml up
```

Browse http://localhost:1080/