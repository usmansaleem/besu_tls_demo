#! /bin/sh
set -e

rm -rf ./data
../besu/build/install/besu/bin/besu --config-file ./tls_config.toml