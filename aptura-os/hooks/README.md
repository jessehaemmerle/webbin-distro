# live-build Hooks

Hooks in this directory are copied by `scripts/build-iso.sh` into
`config/hooks/normal/*.hook.chroot` and run inside the live-build chroot.

Order:

- `010-base-system.sh`: base locale, timezone, APT, and machine identity.
- `020-users-and-groups.sh`: live user, sudo, and group defaults.
- `030-branding.sh`: os-release, Plymouth, wallpaper, and display branding.
- `040-desktop.sh`: desktop session, services, and installer launcher.
- `050-security.sh`: AppArmor, firewall posture, signed APT, and privacy defaults.
- `060-cleanup.sh`: cache cleanup for smaller images.

Hooks must be idempotent. They should tolerate missing packages because package
sets differ between development, CI, and future editions.
