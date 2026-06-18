# Security

Conservative defaults appropriate for a daily-driver desktop, applied by
`aptura-settings` (postinst) and the build hooks.

## Defaults

- **AppArmor** enabled and enforcing (Ubuntu default LSM; also set as default in
  the custom kernel config).
- **UFW** enabled, default deny incoming / allow outgoing. **No SSH server** is
  installed.
- **Automatic security updates** via `unattended-upgrades`
  (`ENABLE_UNATTENDED_UPGRADES=true`; user-disableable).
- **No telemetry**: `popularity-contest`, `apport`, `whoopsie` removed.
- **Privacy**: Wi-Fi MAC randomisation on scan, IPv6 privacy extensions
  (NetworkManager drop-in).
- **Snap removed** in favour of Flatpak by default.
- **sysctl** hardening that does not impede desktop use (kptr/dmesg restrict,
  rp_filter, syncookies).

## Trust boundaries

APT signatures (Ubuntu + Mozilla + future signed Aptura repo), Calamares
privileged steps, PolicyKit actions, D-Bus interfaces. Privileged GUI actions go
through PolicyKit, never directly from the shell.

## Not yet implemented

- **Repository signing** for Aptura packages (`SIGN_REPO=false`); the local repo
  is `[trusted=yes]` only at build time. A real GPG key + public infra is needed
  before distributing updates.
- **Secure Boot**: the custom unsigned kernel requires Secure Boot off or a MOK
  signing flow. See [kernel.md](kernel.md).
