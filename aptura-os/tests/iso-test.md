# Manual ISO Test Checklist

Use a disposable VM disk. Never test installer partitioning on a disk with data
you need.

## Boot

- [ ] ISO boots in BIOS mode.
- [ ] ISO boots in UEFI mode.
- [ ] Boot menu displays Aptura OS naming.
- [ ] Plymouth or boot splash does not block boot logs when troubleshooting.

## Live Session

- [ ] Live session reaches graphical login or autologin desktop.
- [ ] Plasma session starts.
- [ ] Aptura retro-Plasma wallpaper is visible.
- [ ] Plasma panel, launcher, app library, settings, and core apps open.
- [ ] Aptura accent colors and logo assets are visible where Plasma exposes distribution branding.
- [ ] Konsole, Dolphin, and Kate are available.
- [ ] Aptura System Check starts from the launcher and reports local status.
- [ ] Keyboard and touchpad work.
- [ ] Display scaling is usable on small screens.

## Network

- [ ] NetworkManager starts.
- [ ] Wired networking works in VM.
- [ ] Wi-Fi UI is visible on hardware with Wi-Fi.
- [ ] DNS resolution works.

## APT

- [ ] `apt update` succeeds.
- [ ] Debian repositories are signed.
- [ ] No repository uses `trusted=yes`.
- [ ] Aptura packages are installed.
- [ ] Package install works for a small test package.

## Installer

- [ ] Calamares starts from desktop launcher.
- [ ] Welcome page displays Aptura Plasma workstation branding.
- [ ] Locale selection works.
- [ ] Keyboard selection works.
- [ ] Timezone selection works.
- [ ] Automatic whole-disk partitioning works on a disposable disk.
- [ ] Manual partitioning works.
- [ ] Optional encryption path works.
- [ ] User creation works.
- [ ] Summary page clearly describes disk changes.
- [ ] Installation completes.
- [ ] Finish dialog offers reboot.

## Installed System

- [ ] Installed system boots after reboot.
- [ ] Bootloader entry is named Aptura OS.
- [ ] Created user can log in.
- [ ] Created user has sudo access.
- [ ] Root login is disabled.
- [ ] APT works after installation.
- [ ] AppArmor is active or installed with documented status.
- [ ] SSH server is not enabled by default.
- [ ] UFW policy is desktop-friendly.
- [ ] Aptura branding remains visible.

## Privacy And Security

- [ ] No telemetry prompts are enabled by default.
- [ ] No cloud account is required.
- [ ] No unexpected listening services are active.
- [ ] Security update settings match documentation.
- [ ] Calamares did not copy live user secrets into the installed system.
