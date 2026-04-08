#!/usr/bin/env bash
set -euo pipefail

LISTMONK_VERSION=3.0.0

if [ ! -f ./listmonk ]; then
  wget -q "https://github.com/knadh/listmonk/releases/download/v${LISTMONK_VERSION}/listmonk_${LISTMONK_VERSION}_linux_amd64.tar.gz"
  tar xzf "listmonk_${LISTMONK_VERSION}_linux_amd64.tar.gz"
  chmod +x listmonk
  rm -f "listmonk_${LISTMONK_VERSION}_linux_amd64.tar.gz"
fi

chmod +x src/start.sh
chmod +x src/generate-config.sh
echo "Prepare complete."
