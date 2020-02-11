#! /bin/sh
set -e

BESU_INSTALL="$HOME/dev/besu/build/install/besu"

"$BESU_INSTALL/bin/besu" --config-file ./besu_tls_config.toml