# EthSigner Besu Orion TLS Checklist

* Run `clean.sh`
* Run `init.sh`

In terminal window(s)
* Start Orion
~~~
cd orion
start_orion.sh
~~~

* Test Orion is up by using Besu’s privacy TLS keystore
~~~
curl --insecure --cert-type P12 --cert ./besu/orion/keystore/keystore.pfx:changeit https://localhost:8888/upcheck
~~~

* Start Besu
~~~
cd besu
./start_besu.sh
~~~

* Test Besu with EthSigner’s Downstream Keystore
~~~
curl --cert-type P12 --cert ./ethsigner/besu/keystore/keystore.pfx:changeit --insecure -X POST --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' https://127.0.0.1:8545
~~~

* Launch Hashicorp Vault
~~~
cd ethsigner
./1-launchVaultDocker.sh
~~~

* Initialize Hashicorp Vault
~~~
cd ethsigner
./2-initVault.sh
~~~

* Start EthSigner
~~~
cd ethsigner
./3-start_ethsigner.sh
~~~

* Test EthSigner via curl (Using curl client keystore)
Note: privateFrom/privateTo is Orion public/private key (in eea_sendTransaction)
~~~
curl --cert-type P12 --cert ./ethsigner/curl/keystore/keystore.pfx:changeit --insecure -X GET https://127.0.0.1:8646/upcheck

curl --cert-type P12 --cert ./ethsigner/curl/keystore/keystore.pfx:changeit --insecure -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":51}' https://127.0.0.1:8646

curl --cert-type P12 --cert ./ethsigner/curl/keystore/keystore.pfx:changeit --insecure -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{"from": "0xfe3b557e8fb62b89f4916b721be55ceb828dbd73","to": "0xd46e8dd67c5d32be8058bb8eb970870f07244567","gas": "0x7600","gasPrice": "0x9184e72a000","value": "0x9184e72a"}], "id":1}' https://127.0.0.1:8646

curl --cert-type P12 --cert ./ethsigner/curl/keystore/keystore.pfx:changeit --insecure -X POST --data '{"jsonrpc":"2.0","method":"eea_sendTransaction","params":[{"from": "0xfe3b557e8fb62b89f4916b721be55ceb828dbd73","data": "0x608060405234801561001057600080fd5b5060dc8061001f6000396000f3006080604052600436106049576000357c0100000000000000000000000000000000000000000000000000000000900463ffffffff1680633fa4f24514604e57806355241077146076575b600080fd5b348015605957600080fd5b50606060a0565b6040518082815260200191505060405180910390f35b348015608157600080fd5b50609e6004803603810190808035906020019092919050505060a6565b005b60005481565b80600081905550505600a165627a7a723058202bdbba2e694dba8fff33d9d0976df580f57bff0a40e25a46c398f8063b4c00360029", "privateFrom": "negmDcN2P4ODpqn/6WkJ02zT/0w0bjhGpkZ8UP6vARk=","privateFor": ["g59BmTeJIn7HIcnq8VQWgyh/pDbvbt2eyP0Ii60aDDw="],"restriction": "restricted"}], "id":1}' https://127.0.0.1:8646
~~~