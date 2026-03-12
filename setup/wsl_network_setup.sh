#!/usr/bin/env bash
set -euo pipefail
if [[ ! -f /etc/resolv.conf ]]; then
  echo nameserver 8.8.8.8 | sudo tee /etc/resolv.conf >/dev/null
fi
