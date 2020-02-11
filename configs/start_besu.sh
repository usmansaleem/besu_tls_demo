#! /bin/sh
set -e

BESU_INSTALL="$HOME/dev/besu/build/install/besu"
#export JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=n,address=usmans-mbp:5005,suspend=y"

"$BESU_INSTALL/bin/besu" --config-file ./besu_tls_config.toml