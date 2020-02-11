#! /bin/bash

# Initialize Hashicorp vault for EthSigner
# Assuming Hashicorp vault is running in docker and jq utility is available to parse json output

# exit when any command fails
set -e

echo "Init Hashicorp vault"
VAULT_HOST="https://127.0.0.1:8200/v1"
INIT_OUT=$(curl -s -k -X PUT \
    -d '{"secret_shares": 1, "secret_threshold": 1}' "$VAULT_HOST/sys/init" | jq)

VAULT_TOKEN=$(echo $INIT_OUT | jq --raw-output '.root_token')
VAULT_KEY=$(echo $INIT_OUT | jq --raw-output '.keys_base64[0]')

echo "Root Token: $VAULT_TOKEN"
echo "Unseal Key: $VAULT_KEY"

## Unseal ##
echo "Unsealing Hashicorp Vault"
curl -s -k -X PUT -d "{\"key\": \"$VAULT_KEY\"}" "$VAULT_HOST/sys/unseal" | jq

## Enable KV-v2 /secret mount 
echo "Enable kv-v2 secret engine path at /secret"
curl -s -k -X POST -H "X-Vault-Token: $VAULT_TOKEN" \
 -d '{"type": "kv", "options": {"version": "2"}}' "$VAULT_HOST/sys/mounts/secret" | jq

KEY="8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63"
echo "Signing Key (from dev.json): $KEY"

 # Place ethsignerSigningKey
 echo "Create key in vault"
curl -s -k -X POST -H "X-Vault-Token: $VAULT_TOKEN" -d "{\"data\": {\"value\": "\"$KEY\""}}" \
 "$VAULT_HOST/secret/data/ethsignerSigningKey" | jq


 # Obtain EthSigner key
 echo "Reading data back from vault"
 curl -s -k -X GET -H "X-Vault-Token: $VAULT_TOKEN"  "$VAULT_HOST/secret/data/ethsignerSigningKey" \
   | jq '.'

# Write token to authFile
printf $VAULT_TOKEN > ./hashicorpAuthFile
