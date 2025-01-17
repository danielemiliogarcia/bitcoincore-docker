# Bitcoin core docker container

## Build

```
./build.sh
```

## Limitations

* Target platform is hardcoded in Dockerfile, it should be modified for multiple platforms and receive platform by ARG at build

Dockerfile:
```
...
# FIXED HARDCODED TARGET PLATFORM
ENV TARGETPLATFORM=x86_64-linux-gnu
...
```

* No mainnet version yet

## Changelog

Binaries from bitcoincore.org were filing to download, temporary changed to mirrir bitcoin.org which do not have latest versions

## REGTEST
see [regtest/README.md](regtest/README.md)

## TESTNET3
see [testnet3/README.md](testnet3/README.md)
