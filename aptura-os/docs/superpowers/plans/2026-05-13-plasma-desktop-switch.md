# Plasma Desktop Switch Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Switch Aptura OS from COSMIC to KDE Plasma while preserving existing Aptura branding assets and desktop utilities.

**Architecture:** Treat Plasma as the distribution desktop stack and SDDM as the display manager. Keep Aptura branding packages and utility launchers intact, but update visible edition identity from COSMIC to Plasma and remove the external COSMIC OBS repository surface.

**Tech Stack:** Debian live-build config, Calamares YAML modules, Debian package control files, shell validation tests, SVG/text branding assets.

---

## File Structure

- Modify `aptura-os/tests/package-test.sh`: add package metadata assertions for Plasma dependencies and COSMIC removal.
- Modify `aptura-os/tests/smoke-test.sh`: require the new SDDM live-config hook path instead of the old COSMIC greetd hook.
- Modify `aptura-os/scripts/validate.sh`: require Plasma packages, SDDM config, and removal of COSMIC OBS pinning.
- Modify `aptura-os/config/packages.list`: replace COSMIC package block with KDE Plasma packages.
- Modify `aptura-os/packages/aptura-desktop/debian/control`: replace COSMIC dependencies with Plasma/SDDM dependencies.
- Modify `aptura-os/packages/aptura-meta/debian/control`: replace COSMIC dependencies with Plasma/SDDM dependencies.
- Modify `aptura-os/config/apt-sources.list`: remove the COSMIC OBS repository entry and comments.
- Delete `aptura-os/config/live-build/config/archives/cosmic-desktop.list.chroot`, `cosmic-desktop.list.binary`, `cosmic-desktop.key.chroot`, and `cosmic-desktop.key.binary`.
- Delete `aptura-os/config/live-build/config/includes.chroot/etc/apt/preferences.d/60aptura-cosmic-desktop-obs`.
- Delete `aptura-os/packages/aptura-settings/etc/apt/preferences.d/60aptura-cosmic-desktop-obs`.
- Modify `aptura-os/packages/aptura-settings/debian/install`: stop installing the COSMIC OBS APT preference.
- Replace `aptura-os/config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-greetd` with `aptura-os/config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-sddm`.
- Modify `aptura-os/hooks/040-desktop.sh`: configure SDDM and Plasma session defaults instead of COSMIC Greeter.
- Modify `aptura-os/installer/calamares/modules/displaymanager.conf`: select SDDM and Plasma.
- Modify `aptura-os/installer/calamares/modules/services-systemd.conf`: enable SDDM instead of COSMIC Greeter services.
- Modify identity files: `aptura-os/config/distro.env`, `aptura-os/config/branding.conf`, `aptura-os/packages/aptura-branding/etc/aptura/branding.conf`, `aptura-os/packages/aptura-branding/usr/lib/os-release.d/aptura-os-release`, `aptura-os/packages/aptura-branding/etc/profile.d/aptura-branding.sh`, `aptura-os/packages/aptura-branding/etc/motd.d/00-aptura`, and `aptura-os/packages/aptura-desktop/usr/bin/aptura-about`.
- Modify visible docs and SVG text where practical: `README.md`, `docs/*.md`, `desktop/*.md`, `installer/calamares/branding/aptura/branding.desc`, `installer/calamares/branding/aptura/welcome.svg`, and Aptura wallpaper/wordmark SVG text.

### Task 1: Add Plasma Expectations To Tests

**Files:**
- Modify: `aptura-os/tests/package-test.sh`
- Modify: `aptura-os/tests/smoke-test.sh`
- Modify: `aptura-os/scripts/validate.sh`

- [ ] **Step 1: Update package metadata tests**

Add helper checks to `aptura-os/tests/package-test.sh`:

```bash
check_control_depends() {
  local control="$1"
  local package_name="$2"
  if grep -Eq "^[[:space:]]*${package_name},?[[:space:]]*$" "${control}"; then
    ok "$(basename "$(dirname "$(dirname "${control}")")") depends on ${package_name}"
  else
    fail "${control#${ROOT_DIR}/} missing dependency: ${package_name}"
  fi
}

check_control_not_depends() {
  local control="$1"
  local package_name="$2"
  if grep -Eq "^[[:space:]]*${package_name},?[[:space:]]*$" "${control}"; then
    fail "${control#${ROOT_DIR}/} still depends on ${package_name}"
  else
    ok "$(basename "$(dirname "$(dirname "${control}")")") does not depend on ${package_name}"
  fi
}
```

Call them from `main` for both `packages/aptura-desktop/debian/control` and `packages/aptura-meta/debian/control`:

```bash
local desktop_control="${ROOT_DIR}/packages/aptura-desktop/debian/control"
local meta_control="${ROOT_DIR}/packages/aptura-meta/debian/control"
local plasma_dep
for plasma_dep in kde-plasma-desktop plasma-workspace sddm systemsettings dolphin konsole kate ark kde-spectacle plasma-discover xdg-desktop-portal-kde; do
  check_control_depends "${desktop_control}" "${plasma_dep}"
  check_control_depends "${meta_control}" "${plasma_dep}"
done

local cosmic_dep
for cosmic_dep in cosmic-session cosmic-greeter cosmic-greeter-daemon cosmic-comp cosmic-panel cosmic-app-library cosmic-icons cosmic-settings cosmic-files cosmic-term cosmic-edit xdg-desktop-portal-cosmic greetd; do
  check_control_not_depends "${desktop_control}" "${cosmic_dep}"
  check_control_not_depends "${meta_control}" "${cosmic_dep}"
done
```

- [ ] **Step 2: Update smoke test live-config expectation**

Replace:

```bash
require_file config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-greetd
```

with:

```bash
require_file config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-sddm
```

- [ ] **Step 3: Update validation package and repository checks**

In `aptura-os/scripts/validate.sh`, replace COSMIC-specific required files with checks that the COSMIC OBS source and pin files are absent:

```bash
for removed_cosmic_file in \
  "${ROOT_DIR}/config/keyrings/aptura-cosmic-desktop-obs.asc" \
  "${ROOT_DIR}/config/live-build/config/archives/cosmic-desktop.list.chroot" \
  "${ROOT_DIR}/config/live-build/config/archives/cosmic-desktop.list.binary" \
  "${ROOT_DIR}/config/live-build/config/archives/cosmic-desktop.key.chroot" \
  "${ROOT_DIR}/config/live-build/config/archives/cosmic-desktop.key.binary" \
  "${ROOT_DIR}/config/live-build/config/includes.chroot/etc/apt/preferences.d/60aptura-cosmic-desktop-obs" \
  "${ROOT_DIR}/packages/aptura-settings/etc/apt/preferences.d/60aptura-cosmic-desktop-obs"; do
  if [[ -e "${removed_cosmic_file}" ]]; then
    fail "COSMIC OBS file should be removed: ${removed_cosmic_file#${ROOT_DIR}/}"
  fi
done

require_file "${ROOT_DIR}/config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-sddm"
```

Replace the COSMIC package loop with:

```bash
local plasma_pkg
for plasma_pkg in kde-plasma-desktop plasma-workspace sddm systemsettings dolphin konsole kate ark kde-spectacle plasma-discover xdg-desktop-portal-kde; do
  if ! grep -Eq "^[[:space:]]*${plasma_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
    fail "config/packages.list missing Plasma package: ${plasma_pkg}"
  fi
done

local removed_cosmic_pkg
for removed_cosmic_pkg in cosmic-session cosmic-greeter cosmic-greeter-daemon cosmic-comp cosmic-panel cosmic-applets cosmic-app-library cosmic-icons cosmic-launcher cosmic-bg cosmic-idle cosmic-notifications cosmic-osd cosmic-randr cosmic-screenshot cosmic-settings cosmic-settings-daemon cosmic-files cosmic-term cosmic-edit cosmic-player cosmic-wallpapers cosmic-workspaces xdg-desktop-portal-cosmic greetd; do
  if grep -Eq "^[[:space:]]*${removed_cosmic_pkg}([[:space:]]*)$" "${ROOT_DIR}/config/packages.list"; then
    fail "config/packages.list still contains COSMIC package: ${removed_cosmic_pkg}"
  fi
done
```

- [ ] **Step 4: Verify red**

Run:

```bash
bash aptura-os/tests/package-test.sh
bash aptura-os/tests/smoke-test.sh
bash aptura-os/scripts/validate.sh
```

Expected: at least the package and validation tests fail because the repo still contains COSMIC package dependencies and lacks Plasma package dependencies.

### Task 2: Switch Package And Repository Configuration

**Files:**
- Modify: `aptura-os/config/packages.list`
- Modify: `aptura-os/packages/aptura-desktop/debian/control`
- Modify: `aptura-os/packages/aptura-meta/debian/control`
- Modify: `aptura-os/config/apt-sources.list`
- Modify: `aptura-os/packages/aptura-settings/debian/install`
- Delete: COSMIC OBS archive, key, and pin files listed in File Structure

- [ ] **Step 1: Replace package list desktop block**

Replace the COSMIC package block in `config/packages.list` with:

```text
# KDE Plasma desktop.
# Use Debian trixie packages directly so the default desktop stack no longer
# depends on the temporary external COSMIC archive.
kde-plasma-desktop
plasma-workspace
sddm
systemsettings
dolphin
konsole
kate
ark
kde-spectacle
plasma-discover
xdg-desktop-portal-kde
```

Keep the existing workstation and installer package sections after the desktop block.

- [ ] **Step 2: Replace aptura-desktop dependencies**

In `packages/aptura-desktop/debian/control`, replace COSMIC and `greetd` dependencies with:

```text
 kde-plasma-desktop,
 plasma-workspace,
 sddm,
 systemsettings,
 dolphin,
 konsole,
 kate,
 ark,
 kde-spectacle,
 plasma-discover,
 xdg-desktop-portal-kde,
 xwayland,
 xdg-utils,
```

Update the description to "Aptura Plasma desktop integration" and mention KDE Plasma.

- [ ] **Step 3: Replace aptura-meta dependencies**

In `packages/aptura-meta/debian/control`, replace COSMIC and `greetd` dependencies with:

```text
 kde-plasma-desktop,
 plasma-workspace,
 sddm,
 systemsettings,
 dolphin,
 konsole,
 kate,
 ark,
 kde-spectacle,
 plasma-discover,
 xdg-desktop-portal-kde,
 xwayland,
```

- [ ] **Step 4: Remove COSMIC OBS repository surface**

Remove the COSMIC OBS stanza from `config/apt-sources.list`. Delete:

```text
config/live-build/config/archives/cosmic-desktop.list.chroot
config/live-build/config/archives/cosmic-desktop.list.binary
config/live-build/config/archives/cosmic-desktop.key.chroot
config/live-build/config/archives/cosmic-desktop.key.binary
config/live-build/config/includes.chroot/etc/apt/preferences.d/60aptura-cosmic-desktop-obs
packages/aptura-settings/etc/apt/preferences.d/60aptura-cosmic-desktop-obs
```

Remove this line from `packages/aptura-settings/debian/install`:

```text
etc/apt/preferences.d/60aptura-cosmic-desktop-obs etc/apt/preferences.d/
```

- [ ] **Step 5: Verify task**

Run:

```bash
bash aptura-os/tests/package-test.sh
```

Expected: package dependency checks pass; other failures may remain until session and branding files are updated.

### Task 3: Switch Session, Display Manager, And Installer Defaults

**Files:**
- Delete: `aptura-os/config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-greetd`
- Create: `aptura-os/config/live-build/config/includes.chroot/usr/lib/live/config/1170-aptura-sddm`
- Modify: `aptura-os/hooks/040-desktop.sh`
- Modify: `aptura-os/installer/calamares/modules/displaymanager.conf`
- Modify: `aptura-os/installer/calamares/modules/services-systemd.conf`

- [ ] **Step 1: Replace live-config hook**

Create `1170-aptura-sddm` with:

```sh
#!/bin/sh
set -e

COMPONENT="aptura-sddm"
STATE_FILE="/var/lib/live/config/${COMPONENT}"

Init() {
	if [ -e "${STATE_FILE}" ]; then
		exit 0
	fi

	if ! command -v sddm >/dev/null 2>&1; then
		exit 0
	fi

	LIVE_USER_NAME="${LIVE_USERNAME:-${LIVE_USER:-aptura}}"
	if ! id "${LIVE_USER_NAME}" >/dev/null 2>&1; then
		exit 0
	fi

	echo -n " ${COMPONENT}"
}

Config() {
	install -d -m 0755 /etc/sddm.conf.d /var/lib/live/config
	cat > /etc/sddm.conf.d/10-aptura-live.conf <<EOF
[Autologin]
User=${LIVE_USER_NAME}
Session=plasma

[Theme]
Current=breeze
EOF

	touch "${STATE_FILE}"
}

Init
Config
```

Delete the old `1170-aptura-greetd` file.

- [ ] **Step 2: Update desktop hook**

In `hooks/040-desktop.sh`, replace `configure_cosmic_greeter` with `configure_sddm`:

```bash
configure_sddm() {
  local service_path=""
  local candidate

  command -v sddm >/dev/null 2>&1 || return 0

  for candidate in /lib/systemd/system/sddm.service /usr/lib/systemd/system/sddm.service; do
    if [[ -f "${candidate}" ]]; then
      service_path="${candidate}"
      break
    fi
  done

  [[ -n "${service_path}" ]] || return 0

  install -d -m 0755 /etc/X11 /etc/sddm.conf.d /etc/systemd/system
  printf '/usr/bin/sddm\n' > /etc/X11/default-display-manager
  ln -sf "${service_path}" /etc/systemd/system/display-manager.service

  cat > /etc/sddm.conf.d/10-aptura.conf <<'EOF'
[Theme]
Current=breeze
EOF

  enable_service sddm.service
  enable_service display-manager.service
}
```

Call `configure_sddm`. Set AccountsService session to `plasma` when `/usr/share/wayland-sessions/plasma.desktop` or `/usr/share/xsessions/plasma.desktop` exists. Update log text from COSMIC to Plasma.

- [ ] **Step 3: Update Calamares display manager module**

Set `installer/calamares/modules/displaymanager.conf` to:

```yaml
displaymanagers:
  - sddm

defaultDesktopEnvironment:
  executable: "startplasma-wayland"
  desktopFile: "plasma"

basicSetup: true
sysconfigSetup: false
```

- [ ] **Step 4: Update service module**

Replace COSMIC services in `services-systemd.conf` with:

```yaml
services:
  - name: "NetworkManager"
    mandatory: true
  - name: "sddm"
    mandatory: false
  - name: "apparmor"
    mandatory: false
  - name: "bluetooth"
    mandatory: false
  - name: "cups"
    mandatory: false
  - name: "cups-browsed"
    mandatory: false
  - name: "ipp-usb"
    mandatory: false
  - name: "fwupd-refresh.timer"
    mandatory: false
  - name: "power-profiles-daemon"
    mandatory: false

disable:
  - "ssh"
  - "sshd"
```

- [ ] **Step 5: Verify task**

Run:

```bash
bash aptura-os/tests/smoke-test.sh
bash aptura-os/scripts/validate.sh
```

Expected: smoke test passes; validation may still fail on branding text until Task 4.

### Task 4: Update Visible Edition Identity While Preserving Branding

**Files:**
- Modify: identity and branding text files listed in File Structure

- [ ] **Step 1: Update config identity values**

Use these values where corresponding keys exist:

```text
DISTRO_PRETTY_NAME="Aptura OS 0.1.4 Adeline Plasma"
DESKTOP_NAME="Aptura Plasma"
ISO_LABEL="Aptura OS Adeline Plasma Live"
PRETTY_NAME="Aptura OS 0.1.4 Adeline Plasma"
DEFAULT_MODE="plasma"
VARIANT="Plasma"
VARIANT_ID=plasma
```

Keep existing colors, wallpaper paths, logo paths, `THEME_NAME="Aptura-COSMIC"`, and `ICON_THEME_NAME="Aptura-COSMIC"` unless a future migration renames those asset namespaces.

- [ ] **Step 2: Update user-facing scripts**

In `aptura-about`, use:

```bash
message="Aptura OS 0.1.4 Adeline Plasma

A Debian-compatible desktop distribution with KDE Plasma, Aptura branding, practical defaults, and workstation tooling.

Edition: Adeline Plasma
Base: Debian trixie
Kernel channel: trixie-backports"
```

In `aptura-welcome`, replace "COSMIC edition" with "Plasma edition" and replace references to COSMIC apps with KDE equivalents where the command is user-facing.

In `aptura-shift` and `aptura-mode`, replace user-facing COSMIC settings hints with Plasma System Settings hints.

- [ ] **Step 3: Update branding text assets**

Update SVG text and metadata that literally says COSMIC edition/workstation to Plasma, including:

```text
installer/calamares/branding/aptura/branding.desc
installer/calamares/branding/aptura/welcome.svg
packages/aptura-branding/usr/share/aptura/branding/aptura-wordmark.svg
packages/aptura-branding/usr/share/backgrounds/aptura/aptura-default.svg
packages/aptura-branding/usr/share/backgrounds/aptura/aptura-retro-cosmic.svg
packages/aptura-branding/usr/share/backgrounds/aptura/aptura-context-grid.svg
packages/aptura-branding/usr/share/plymouth/themes/aptura/aptura.script
```

Do not delete or replace the artwork itself.

- [ ] **Step 4: Verify task**

Run:

```bash
rg -n "Adeline COSMIC|Aptura COSMIC|COSMIC edition|COSMIC workstation|System76 COSMIC|DEFAULT_MODE=\"cosmic\"|VARIANT_ID=cosmic" aptura-os
```

Expected: no matches in active runtime/config/branding files, except historical changelog or docs that explicitly discuss past COSMIC work.

### Task 5: Update Docs And Final Validation

**Files:**
- Modify: `aptura-os/README.md`
- Modify: `aptura-os/docs/architecture.md`
- Modify: `aptura-os/docs/package-management.md`
- Modify: `aptura-os/docs/desktop-concept.md`
- Modify: `aptura-os/docs/roadmap.md`
- Modify: `aptura-os/docs/release-process.md`
- Modify: `aptura-os/docs/security.md`
- Modify: `aptura-os/tests/iso-test.md`
- Modify: `aptura-os/packages/README.md`
- Modify: `aptura-os/desktop/README.md`
- Modify: `aptura-os/desktop/greeter-theme/README.md`
- Modify: `aptura-os/desktop/settings-center/README.md`
- Modify: `aptura-os/desktop/wallpapers/README.md`
- Modify: `aptura-os/packages/aptura-desktop/usr/share/aptura-desktop/README.md`
- Modify changelogs only if adding a concise unreleased entry is consistent with nearby package history.

- [ ] **Step 1: Update docs language**

Replace current-desktop language so docs describe KDE Plasma, SDDM, Debian archive packages, and preserved Aptura branding. Leave historical changelog entries intact.

- [ ] **Step 2: Run full repository checks**

Run:

```bash
bash aptura-os/tests/package-test.sh
bash aptura-os/tests/smoke-test.sh
bash aptura-os/scripts/validate.sh
```

Expected: shell tests exit 0. `validate.sh` may print warnings for missing Linux-only build tools on Windows; warnings are acceptable, failures are not.

- [ ] **Step 3: Inspect remaining COSMIC references**

Run:

```bash
rg -n "cosmic|COSMIC|greetd|xdg-desktop-portal-cosmic|aptura-cosmic-desktop-obs" aptura-os
```

Expected: remaining matches are limited to historical changelogs, old Superpowers plan/spec context, or asset namespace paths intentionally retained as `Aptura-COSMIC`.

- [ ] **Step 4: Review diff**

Run:

```bash
git diff --stat
git diff -- aptura-os/config/packages.list aptura-os/packages/aptura-desktop/debian/control aptura-os/packages/aptura-meta/debian/control aptura-os/scripts/validate.sh
```

Expected: diff shows Plasma/SDDM replacement and no unrelated deletion of Aptura branding assets or utility launchers.
