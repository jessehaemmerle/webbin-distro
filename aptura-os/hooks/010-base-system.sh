#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '[010-base-system] %s\n' "$*"
}

log "Configuring locales and base system defaults"

cat > /etc/locale.gen <<'EOF'
en_US.UTF-8 UTF-8
de_DE.UTF-8 UTF-8
EOF

if command -v locale-gen >/dev/null 2>&1; then
  locale-gen
fi

if command -v update-locale >/dev/null 2>&1; then
  update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en
fi

ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "Etc/UTC" > /etc/timezone

cat > /etc/hostname <<'EOF'
aptura-live
EOF

cat > /etc/hosts <<'EOF'
127.0.0.1 localhost
127.0.1.1 aptura-live

::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

install -d -m 0755 /etc/apt/apt.conf.d
cat > /etc/apt/apt.conf.d/99aptura-hardening <<'EOF'
APT::Get::AllowUnauthenticated "false";
Acquire::AllowInsecureRepositories "false";
Acquire::AllowDowngradeToInsecureRepositories "false";
Acquire::Retries "3";
EOF

log "Base system defaults complete"
