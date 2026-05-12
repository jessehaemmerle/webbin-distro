#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[060-cleanup] %s\n' "$*"
}

log "Cleaning package caches and transient files"

apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/* /var/tmp/*
rm -f /etc/machine-id
touch /etc/machine-id

log "Cleanup complete"
