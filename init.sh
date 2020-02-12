#! /bin/bash
set -e

ORION_INSTALL="$HOME/dev/orion/build/install/orion/"

# Keystores in Besu
BESU_KEYSTORE="./besu/keystore/keystore.pfx"
BESU_PASSWORD_FILE="./besu/keystore/password.txt"
BESU_KNOWN_CLIENTS_FILE="./besu/keystore/knownClients.txt"

BESU_ORION_NODE_KEY="./besu/orion/nodeKey.pub"
BESU_ORION_PRIV_KEYSTORE="./besu/orion/keystore/keystore.pfx"
BESU_ORION_PRIV_PASSWORD_FILE="./besu/orion/keystore/password.txt"
BESU_ORION_PRIV_KNOWN_SERVER_FILE="./besu/orion/keystore/knownServers.txt"

# Keystores in Orion
ORION_PEM="./orion/keystore/orion_for_besu.pem"
ORION_KEY="./orion/keystore/orion_for_besu.key" 

# Keystores in EthSigner
ETHSIGNER_KEYSTORE="./ethsigner/keystore/keystore.pfx"
ETHSIGNER_PASSWORD_FILE="./ethsigner/keystore/password.txt"
ETHSIGNER_TLS_KNOWN_CLIENTS="./ethsigner/keystore/knownClients.txt"
ETHSIGNER_BESU_AUTH_KEYSTORE="./ethsigner/besu/keystore/keystore.pfx"
ETHSIGNER_BESU_AUTH_PASSWORD_FILE="./ethsigner/besu/keystore/password.txt"
ETHSIGNER_BESU_AUTH_KNOWN_SERVER_FILE="./ethsigner/besu/keystore/knownBesuServers.txt"
ETHSIGNER_CURL_CLIENT_KEYSTORE="./ethsigner/curl/keystore/keystore.pfx"

# internal usage
_ORION_KEYSTORE="./orion/keystore/keystore.pfx"

mkdir -p ./besu/keystore
mkdir -p ./besu/orion/keystore
mkdir -p ./orion/keystore
mkdir -p ./ethsigner/keystore/
mkdir -p ./ethsigner/besu/keystore/
mkdir -p ./ethsigner/curl/keystore/

echo "Generating self signed certificates ..."
# Besu Self Signed Certificate
keytool -genkeypair -keystore "$BESU_KEYSTORE" -storetype PKCS12 -storepass changeit -alias besu_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=besu_test, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1

# Besu (for connecting to Orion) Self Signed Certificate
keytool -genkeypair -keystore "$BESU_ORION_PRIV_KEYSTORE" -storetype PKCS12 -storepass changeit -alias besu_orion_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=besu_privacy_test, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1

# Orion Self Signed Certificate
keytool -genkeypair -keystore "$_ORION_KEYSTORE" -storetype PKCS12 -storepass changeit -alias orion_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=orion_test, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1

# Export Orion key/certificate from PKCS12 to PEM
keytool -exportcert -keystore "$_ORION_KEYSTORE" -storepass changeit -alias orion_certs -rfc -file "$ORION_PEM"
openssl pkcs12 -in "$_ORION_KEYSTORE" -nocerts -nodes -passin pass:changeit | openssl rsa -out "$ORION_KEY"

# EthSigner Self Signed Certificate
keytool -genkeypair -keystore "$ETHSIGNER_KEYSTORE" -storetype PKCS12 -storepass changeit -alias ethsigner_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=ethsigner_test, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1

# EthSigner Self Signed Certificate for downstream client auth (when connecting to Besu)
keytool -genkeypair -keystore "$ETHSIGNER_BESU_AUTH_KEYSTORE" -storetype PKCS12 -storepass changeit -alias ethsigner_besu_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=ethsigner_besu_test, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1

# Curl Self Signed Certificate for connecting to EthSigner
keytool -genkeypair -keystore "$ETHSIGNER_CURL_CLIENT_KEYSTORE" -storetype PKCS12 -storepass changeit -alias curl_certs \
-keyalg RSA -keysize 2048 -validity 700 -dname "CN=curl, OU=PegaSys, O=ConsenSys, L=Brisbane, ST=QLD, C=AU" \
-ext san=dns:localhost,ip:127.0.0.1

echo "Generating keystore password files"
printf "changeit" > "$BESU_PASSWORD_FILE"
printf "changeit" > "$BESU_ORION_PRIV_PASSWORD_FILE"
printf "changeit" > "$ETHSIGNER_PASSWORD_FILE"
printf "changeit" > "$ETHSIGNER_BESU_AUTH_PASSWORD_FILE"


BESU_SHA256=`openssl pkcs12 -in $BESU_KEYSTORE -nodes -passin pass:changeit -nomacver | openssl x509 -sha256 -fingerprint -noout | awk -F'=' '{print $2}'`
BESU_ORION_SHA256=`openssl pkcs12 -in $BESU_ORION_PRIV_KEYSTORE -nodes -passin pass:changeit -nomacver | openssl x509 -sha256 -fingerprint -noout | awk -F'=' '{print $2}'`
ORION_SHA256=`openssl x509 -in $ORION_PEM -sha256 -fingerprint -noout | awk -F'=' '{print $2}'`
ETHSIGNER_SHA256=`openssl pkcs12 -in $ETHSIGNER_KEYSTORE -nodes -passin pass:changeit -nomacver | openssl x509 -sha256 -fingerprint -noout | awk -F'=' '{print $2}'`
ETHSIGNER_BESU_SHA256=`openssl pkcs12 -in $ETHSIGNER_BESU_AUTH_KEYSTORE -nodes -passin pass:changeit -nomacver | openssl x509 -sha256 -fingerprint -noout | awk -F'=' '{print $2}'`
CURL_ETHSIGNER_SHA256=`openssl pkcs12 -in $ETHSIGNER_CURL_CLIENT_KEYSTORE -nodes -passin pass:changeit -nomacver | openssl x509 -sha256 -fingerprint -noout | awk -F'=' '{print $2}'`

echo "Besu Fingerprint: $BESU_SHA256"
echo "Besu-Orion Fingerprint: $BESU_ORION_SHA256"
echo "Orion Fingerprint: $ORION_SHA256"
echo "EthSigner Fingerprint: $ETHSIGNER_SHA256"
echo "EthSigner-Besu Fingerprint: $ETHSIGNER_BESU_SHA256"

echo "Copying Orion scripts"
cp ./configs/start_orion.sh ./orion/
cp ./configs/orion.conf ./orion/

echo "Generating Orion Keys"
yes 123456 | "$ORION_INSTALL/bin/orion" -g ./orion/nodeKey

ORION_PUB_KEY=`cat ./orion/nodeKey.pub`

# Create password file
echo "Generating Orion password file"
cat << EOF > ./orion/passwordFile
123456
EOF

# create knownClients.txt by adding Besu_Orion fingerprint
echo "Generating Orion knownClients.txt"
cat << EOF > ./orion/keystore/knownClients.txt
besu_privacy_test $BESU_ORION_SHA256
EOF

echo "Copying besu scripts ..."
cp ./configs/start_besu.sh ./besu/
cp ./configs/besu_tls_config.toml ./besu/
cp ./orion/nodeKey.pub ./besu/orion/

# create knownServers.txt by adding Orion fingerprint
echo "Generating Besu-Orion knownServers.txt"
cat << EOF > $BESU_ORION_PRIV_KNOWN_SERVER_FILE
localhost:8888 $ORION_SHA256
127.0.0.1:8888 $ORION_SHA256
EOF

# create Besu knownClients.txt by adding EthSigner_Besu fingerprint
echo "Generating Besu knownClients.txt"
cat << EOF > $BESU_KNOWN_CLIENTS_FILE
ethsigner_besu_test $ETHSIGNER_BESU_SHA256
EOF

# Copy EthSigner configs and scripts
echo "Copying EthSigner scripts ..."
cp "./configs/1-launchVaultDocker.sh" ./ethsigner/
cp "./configs/2-initVault.sh" ./ethsigner/
cp "./configs/3-start_ethsigner.sh" ./ethsigner/

# create knownServers.txt by adding Besu fingerprint
echo "Generating EthSigner-Besu knownServers.txt"
cat << EOF > $ETHSIGNER_BESU_AUTH_KNOWN_SERVER_FILE
localhost:8545 $BESU_SHA256
127.0.0.1:8545 $BESU_SHA256
EOF

# create EthSigner knownClients.txt by adding CURL certificate fingerprint
echo "Generating Curl-EthSigner knownClients.txt"
cat << EOF > $ETHSIGNER_TLS_KNOWN_CLIENTS
curl $CURL_ETHSIGNER_SHA256
EOF

echo "curl test command for EthSigner"
echo "curl --cert-type P12 --cert ./ethsigner/curl/keystore/keystore.pfx:changeit --insecure -X POST \
   --data '{\"jsonrpc\":\"2.0\",\"method\":\"eea_sendTransaction\",\"params\":[{\"from\": \"0xfe3b557e8fb62b89f4916b721be55ceb828dbd73\" \
   ,\"data\": \"0x608060405234801561001057600080fd5b5060dc8061001f6000396000f3006080604052600436106049576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633fa4f24514604e57806355241077146076575b600080fd5b348015605957600080fd5b50606060a0565b6040518082815260200191505060405180910390f35b348015608157600080fd5b50609e6004803603810190808035906020019092919050505060a6565b005b60005481565b80600081905550505600a165627a7a723058202bdbba2e694dba8fff33d9d0976df580f57bff0a40e25a46c398f8063b4c00360029\", \
   \"privateFrom\": \"$ORION_PUB_KEY\",\"privateFor\": [\"$ORION_PUB_KEY\"],\"restriction\": \"restricted\"}], \"id\":1}' https://127.0.0.1:8646"