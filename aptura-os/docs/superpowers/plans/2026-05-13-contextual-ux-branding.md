# Contextual UX And Branding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add five distinctive Aptura UX features plus matching desktop branding assets and validation.

**Architecture:** Keep the existing Debian package pattern: one Bash tool, one desktop launcher, install entries, icons, docs, and tests. State is local-only through `aptura-journey`; no network calls and no persistent daemon are introduced.

**Tech Stack:** Bash, Debian package skeletons, freedesktop `.desktop` files, SVG icons/wallpaper, GTK CSS/settings, repository shell tests.

---

### Task 1: Test Coverage For New UX Features

**Files:**
- Modify: `aptura-os/tests/package-test.sh`
- Modify: `aptura-os/tests/smoke-test.sh`
- Modify: `aptura-os/scripts/validate.sh`

- [ ] Add the five new feature names to the reusable package feature test list: `aptura-journey`, `aptura-context`, `aptura-shift`, `aptura-aftercare`, `aptura-live-bridge`.
- [ ] Add checks for matching Aptura-COSMIC and hicolor icons.
- [ ] Add smoke checks for executability.
- [ ] Add validation checks for scripts, desktop files, icons, context-grid wallpaper, and GTK skeleton settings.
- [ ] Run `bash aptura-os/tests/package-test.sh` and verify it fails because the new files are missing.

### Task 2: Implement Feature Scripts And Launchers

**Files:**
- Create: `aptura-os/packages/aptura-desktop/usr/bin/aptura-journey`
- Create: `aptura-os/packages/aptura-desktop/usr/bin/aptura-context`
- Create: `aptura-os/packages/aptura-desktop/usr/bin/aptura-shift`
- Create: `aptura-os/packages/aptura-desktop/usr/bin/aptura-aftercare`
- Create: `aptura-os/packages/aptura-desktop/usr/bin/aptura-live-bridge`
- Create: corresponding `.desktop` files under `aptura-os/packages/aptura-desktop/usr/share/applications`
- Modify: `aptura-os/packages/aptura-desktop/debian/install`

- [ ] Implement local-only journey logging.
- [ ] Implement context detection without requiring privileged commands.
- [ ] Implement shift profiles with optional `powerprofilesctl`.
- [ ] Implement aftercare checks for reboot, failed units, disk, snapshots, APT history, and restart tooling.
- [ ] Implement live bridge readiness checks plus `--report`.
- [ ] Add all scripts and launchers to `debian/install`.
- [ ] Run `bash aptura-os/tests/package-test.sh` and verify remaining failures are branding assets.

### Task 3: Implement Desktop Branding Assets

**Files:**
- Create new SVG icons in `aptura-os/packages/aptura-branding/usr/share/icons/Aptura-COSMIC/scalable/apps`
- Create matching SVG icons in `aptura-os/packages/aptura-branding/usr/share/icons/hicolor/scalable/apps`
- Create: `aptura-os/packages/aptura-branding/usr/share/backgrounds/aptura/aptura-context-grid.svg`
- Modify: `aptura-os/packages/aptura-branding/usr/share/themes/Aptura-COSMIC/gtk-3.0/gtk.css`
- Modify: `aptura-os/packages/aptura-branding/etc/aptura/branding.conf`
- Modify: `aptura-os/config/branding.conf`
- Modify: `aptura-os/hooks/030-branding.sh`

- [ ] Add five tool icons with a consistent retro-COSMIC motif.
- [ ] Add context-grid wallpaper and install it through the existing wildcard.
- [ ] Tune GTK fallback colors toward deep Aptura navy, teal action, magenta signal, amber warning, and crisp retro borders.
- [ ] Set the new wallpaper as the default branding wallpaper where the repository defines defaults.
- [ ] Run `bash aptura-os/tests/package-test.sh` and verify remaining failures are settings/docs if any.

### Task 4: Add Desktop Defaults And Documentation

**Files:**
- Create: `aptura-os/packages/aptura-settings/etc/skel/.config/gtk-3.0/settings.ini`
- Create: `aptura-os/packages/aptura-settings/etc/skel/.config/gtk-4.0/settings.ini`
- Modify: `aptura-os/packages/aptura-settings/debian/install`
- Modify: `aptura-os/packages/aptura-desktop/usr/share/aptura-desktop/README.md`
- Modify: `aptura-os/desktop/README.md`
- Modify: `aptura-os/docs/desktop-concept.md`
- Modify: `aptura-os/README.md`

- [ ] Install GTK skeleton defaults for theme, icon theme, and dark preference.
- [ ] Document the five features as the contextual UX layer.
- [ ] Document the stronger desktop branding defaults.
- [ ] Run `bash aptura-os/tests/package-test.sh` and verify it passes.

### Task 5: Final Verification

**Files:**
- No new files.

- [ ] Run `bash aptura-os/tests/smoke-test.sh`.
- [ ] Run `bash aptura-os/tests/package-test.sh`.
- [ ] Run non-mutating script checks: `aptura-journey --help`, `aptura-context --help`, `aptura-shift --help`, `aptura-aftercare --help`, `aptura-live-bridge --help`.
- [ ] Run `git diff --check`.
- [ ] Summarize changed files and any host limitations.
