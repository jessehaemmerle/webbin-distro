# Aptura Desktop Integration

`aptura-desktop` installs Aptura Shell, the default Wayland desktop session,
while keeping KDE Plasma available as a fallback and application base.

Included integration points:

- Aptura Journey (`aptura-journey`) for a local-only record of context checks,
  profile shifts, live-readiness reports, and aftercare runs.
- Aptura Context (`aptura-context`) for detecting live sessions, VMs, laptop
  state, battery, networking, boot mode, and storage pressure.
- Aptura Shift (`aptura-shift`) for code, study, create, game, travel, and
  focus workstation rituals backed by available power profiles.
- Aptura Aftercare (`aptura-aftercare`) for post-update and post-install
  checks covering reboot, failed units, snapshots, disk pressure, and restart
  tooling.
- Aptura Live Bridge (`aptura-live-bridge`) for live-session install readiness
  checks and local readiness reports.
- Aptura System Check for local update, firmware, power, security, and disk
  status.
- Aptura Safe Update for best-effort Timeshift snapshots before package
  upgrades.
- Aptura Rescue Center for boot, EFI, GRUB, disk, and installer recovery
  context.
- Aptura Privacy Check for firewall, exposed services, MAC privacy, and
  listening sockets.
- Aptura Modes for balanced, performance, battery, studio, and focus profiles.
- Aptura Support Bundle for redacted diagnostics archives that are easier to
  share.
- Aptura Welcome for a one-time first-run handoff into System Check.
- Aptura Shell session, SDDM, context-grid wallpaper, icon, GTK fallback theme,
  panel, launcher, and appearance defaults from `aptura-branding` and
  `aptura-settings`.
- Firmware, power profile, disk, backup, snapshot, diagnostics, printing,
  scanning, and software management packages.
- Installer launcher integration for the live session.
