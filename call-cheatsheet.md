# Bitcoin Node Calls Cheatsheet
source : https://github.com/ruimarinho/docker-bitcoin-core

## Spin a Regtest Node in Docker

```bash
docker run --rm --name bitcoin-server -it \
  -p 18443:18443 \
  -p 18444:18444 \
  ruimarinho/bitcoin-core:24.0.1 \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcbind=0.0.0.0 \
  -rpcauth='bituser:337f951003371b21ba0a964464a1d34a$591adbcccece2e5bc1fdd8426c3aa9441a8a6c5cf0fa9a3ed6f7f53029e76130' \
  -fallbackfee=0.0001 \
  -minrelaytxfee=0.00001 \
  -maxtxfee=10000000 -txindex
```

## Get a Shell Inside the Container and Run Commands

### Get Info
```bash
bitcoin-cli -regtest -rpcuser=bituser -rpcpassword="bitpass" -getinfo
```

### Get Network Info
```bash
bitcoin-cli -regtest getnetworkinfo | jq
```

### Mempool Logging ON
```bash
bitcoin-cli -regtest logging '{"mempool":true}'
```

### Create a Wallet
```bash
bitcoin-cli -regtest -rpcuser=bituser -rpcpassword="bitpass" createwallet wallet_test
```

### List Wallets
```bash
bitcoin-cli -regtest listwallets
```

### Get New Address
```bash
bitcoin-cli -regtest -rpcuser=bituser -rpcpassword="bitpass" getnewaddress
```

### Generate to Address (Mine 1 Block to Address)
```bash
bitcoin-cli -regtest -rpcuser=bituser -rpcpassword="bitpass" generatetoaddress <NUM_BLOCKS> <ADDRESS>
bitcoin-cli -regtest -rpcuser=bituser -rpcpassword="bitpass" generatetoaddress 1 bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y
```

### Generate to Address with User Exec
```bash
bitcoin-cli -regtest generatetoaddress 1 bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y
```

### Send to Address 0.1 BTC
```bash
bitcoin-cli -regtest sendtoaddress bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y 0.1
```

### Get Mining Info
```bash
bitcoin-cli -regtest getmininginfo
```

### Get Block Count
```bash
bitcoin-cli -regtest getblockcount
```

### Get Best Block Hash
```bash
bitcoin-cli -regtest getbestblockhash
```

### Reorg Last 3 Blocks
```bash
LAST_BLOCK=$(bitcoin-cli -regtest getblockcount)
TARGET_BLOCK=$((LAST_BLOCK - 3))
BLOCK_HASH=$(bitcoin-cli -regtest getblockhash $TARGET_BLOCK)

bitcoin-cli -regtest invalidateblock $BLOCK_HASH
bitcoin-cli -regtest generatetoaddress 3 "bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y"
```

### Script to See Last 5 Blocks
```bash
# Get the current block count
LAST_BLOCK=$(bitcoin-cli -regtest getblockcount)

# Loop to print the last 5 blocks
for ((i=0; i<5; i++)); do
    # Calculate the block number
    BLOCK_NUMBER=$((LAST_BLOCK - i))

    # Get the block hash for the block number
    BLOCK_HASH=$(bitcoin-cli -regtest getblockhash $BLOCK_NUMBER)

    # Print the block number and block hash
    echo "$BLOCK_NUMBER : -> $BLOCK_HASH"
done
```

## Mine a Block (Spinning Another Container and Connecting, Then Removing the Container)
```bash
docker run -it --link bitcoin-server --rm ruimarinho/bitcoin-core \
  bitcoin-cli \
  -rpcconnect=bitcoin-server \
  -regtest \
  -rpcuser=bituser\
  -rpcpassword="bitpass" \
  generatetoaddress 1 <miner_address>
```

### Mine a Block in One Line
```bash
docker run -it --link bitcoin-server --rm ruimarinho/bitcoin-core bitcoin-cli -rpcconnect=bitcoin-server -regtest -rpcuser=bituser -rpcpassword="bitpass" generatetoaddress 1 bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y
```

## Mine a Block (Using Docker Exec in the Same Container)
```bash
docker exec bitcoin-server bitcoin-cli -regtest -rpcuser=bituser -rpcpassword="bitpass" generatetoaddress 1 bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y
```

## Mine a Block with User Exec
```bash
docker exec --user bitcoin bitcoin-server bitcoin-cli -regtest generatetoaddress 1 bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y
```

## Get Mining Info Exec (User Instead of RPC)
```bash
docker exec --user bitcoin bitcoin-server bitcoin-cli -regtest getmininginfo
```


## Create wallet to generate blocks to that wallet
```bash
docker exec --user bitcoin bitcoin-server bitcoin-cli -regtest createwallet testwallet
```

## Mine a block simple (needs a wallet)
```bash
docker exec --user bitcoin bitcoin-server bitcoin-cli -regtest -generate 1
```


## RPC Using CURL

### Get Network Info
```bash
curl -d '{"jsonrpc":"1.0","id":"1","method":"getnetworkinfo","params":[]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
```

### Mine a Block
```bash
curl -d '{"jsonrpc":"1.0","id":"1","method":"generatetoaddress","params":[1,"bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y"]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
```

### Mibe a Block every 3 secs
```bash
while true; do
  curl -d '{"jsonrpc":"1.0","id":"1","method":"generatetoaddress","params":[1,"bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y"]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
  sleep 3
done
```

### Send to Address 0.1 BTC
```bash
curl -d '{"jsonrpc":"1.0","id":"1","method":"sendtoaddress","params":["bcrt1qpka2saadan0vgs2vlf7x2ywl9r5k7wu3yfa83y", 0.1]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
```

### Create Wallet
```bash
curl -d '{"jsonrpc":"1.0","id":"1","method":"createwallet","params":["testwallet2"]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
```

### Get Blockchain Info
```bash
curl -d '{"jsonrpc":"1.0","id":"1","method":"getblockchaininfo","params":[]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
```

### Get Block Count
```bash
curl -d '{"jsonrpc":"1.0","id":"1","method":"getblockcount","params":[]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
```

### Get Best Block Hash
```bash
curl -d '{"jsonrpc":"1.0","id":"1","method":"getbestblockhash","params":[]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
```

### Decode Raw Transaction
```bash
curl -d '{"jsonrpc":"1.0","id":"1","method":"decoderawtransaction","params":["RAW_TX_HERE"]}' http://bituser:bitpass@127.0.0.1:18443/ | jq
```
