#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for sugarchaind"

  set -- sugarchaind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "sugarchaind" ]; then
  mkdir -p "$SUGAR_DATA"
  chmod 700 "$SUGAR_DATA"
  chown -R sugarchain "$SUGAR_DATA"

  echo "$0: setting data directory to $SUGAR_DATA"

  set -- "$@" -datadir="$SUGAR_DATA"
fi

if [ "$1" = "sugarchaind" ] || [ "$1" = "sugarchain-cli" ] || [ "$1" = "sugarchain-tx" ]; then
  echo
  exec su-exec sugarchain "$@"
fi

echo
exec "$@"