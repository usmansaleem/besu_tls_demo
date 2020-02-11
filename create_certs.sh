#! /bin/bash
set -ex

BESU_KEYSTORE="./besu/keystore/keystore.pfx"
ORION_KEYSTORE="./orion/keystore/keystore.pfx"
ETHSIGNER_KEYSTORE="./ethsigner/keystore/keystore.pfx"

BESU_PASSWORD_FILE="./besu/keystore/password.txt"
ORION_PASSWORD_FILE="./orion/keystore/password.txt"
ETHSIGNER_PASSWORD_FILE="./ethsigner/keystore/password.txt"

mkdir -p ./besu/keystore
mkdir -p ./orion/keystore
mkdir -p ./ethsigner/keystore

[ -f $BESU_KEYSTORE ] && rm $BESU_KEYSTORE
[ -f $ORION_KEYSTORE ] && rm $ORION_KEYSTORE
[ -f $ETHSIGNER_KEYSTORE ] && rm $ETHSIGNER_KEYSTORE

echo "Generating self signed certificates in ./keystore ..."
# Besu Self Signed Certificate
keytool -genkeypair -keystore "$BESU_KEYSTORE" -storetype PKCS12 -storepass changeit -alias besu_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=besu_test, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1
 
# Orion Self Signed Certificate
keytool -genkeypair -keystore "$ORION_KEYSTORE" -storetype PKCS12 -storepass changeit -alias orion_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=orion_test, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1

# EthSigner Self Signed Certificate
keytool -genkeypair -keystore "$ETHSIGNER_KEYSTORE" -storetype PKCS12 -storepass changeit -alias ethsigner_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=ethsigner_test, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1

echo "Generating password files in ./keystore"
echo "changeit" > "$BESU_PASSWORD_FILE"
echo "changeit" > "$ORION_PASSWORD_FILE"
echo "changeit" > "$ETHSIGNER_PASSWORD_FILE"
