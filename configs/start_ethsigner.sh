#! /bin/bash

ETHSIGNER_INSTALL="$HOME/dev/ethsigner/build/install/ethsigner"

"$ETHSIGNER_INSTALL/bin/ethsigner" --chain-id=2018 --http-listen-port=8646  \
 --tls-keystore-file=./keystore/keystore.pfx --tls-keystore-password-file=./keystore/password.txt \
 --tls-known-clients-file=./ethsigner/keystore/knownClients.txt \
 --downstream-http-port=8545 --downstream-http-tls-enabled --downstream-http-tls-keystore-file=./besu/keystore/keystore.pfx \
 --downstream-http-tls-keystore-password-file=./besu/keystore/password.txt \
 --downstream-http-tls-known-servers-file=./besu/keystore/knownBesuServers.txt \
 -l INFO \
 hashicorp-signer --host=localhost --port=8200 --auth-file=./hashicorpAuthFile --tls-known-server-file=./hashicorpKnownServers.txt