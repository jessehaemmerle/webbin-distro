# Aptura Contextual UX And Branding Design

## Goal

Make Aptura feel less like a generic Debian COSMIC remix and more like a local, attentive workstation distribution. The new experience should be state-aware, privacy-preserving, scriptable, and aligned with the existing Aptura retro-COSMIC identity.

## Feature Set

1. `aptura-journey` stores a local-only system journey log under `XDG_STATE_HOME` or `~/.local/state/aptura`. It records meaningful Aptura events such as context checks, profile shifts, aftercare runs, and live-session readiness reports.
2. `aptura-context` detects whether the user is in a live session, VM, laptop, desktop, offline state, low-space state, UEFI/BIOS boot, or battery-sensitive context. It prints concise status plus suggested next steps.
3. `aptura-shift` provides workstation rituals for `code`, `study`, `create`, `game`, `travel`, and `focus`. It maps those intents to power profiles when available, prints practical launch hints, and records the shift locally.
4. `aptura-aftercare` runs after updates or whenever the user asks "what now?". It checks reboot recommendations, failed units, disk pressure, snapshots, recent APT history, and restart tooling.
5. `aptura-live-bridge` gives the live ISO a distinct handoff experience. It explains what is temporary, checks install readiness, and can write a shareable local readiness report.

## Desktop Branding

Branding should reinforce the new state-aware tools:

- Add matching Aptura-COSMIC icons for the five new tools in both the Aptura icon theme and hicolor application namespace.
- Add a context-grid wallpaper variant that visually connects Journey, Shift, Live, Aftercare, and Context as workstation signals.
- Tune GTK fallback colors toward the Aptura identity: deep navy title surfaces, teal action accents, magenta secondary signals, amber warnings, and sharper retro workstation contrast.
- Add GTK skeleton settings so new users default to Aptura-COSMIC theme and icon theme where GTK honors those settings.
- Update desktop integration documentation and package metadata so the new experience is discoverable.

## Architecture

Each feature is a focused Bash script in `packages/aptura-desktop/usr/bin`, with a `.desktop` launcher in `usr/share/applications`. Shared behavior stays intentionally small and duplicated only where it keeps scripts independent. Cross-tool memory is only the local Journey log, not a daemon or network service.

`aptura-daily-check` is intentionally not part of this round; the approved direction is more distinctive when state is visible through explicit rituals and live/session context instead of another background reminder.

## Error Handling

Scripts must degrade cleanly when optional tools are missing. They print `unavailable`, `not detected`, or a concrete next step instead of failing hard. Commands that need root do not run automatically. Report generation writes under the user's home directory by default.

## Testing

Repository tests validate that every new feature has:

- executable script,
- desktop launcher,
- install entry,
- icon asset in both Aptura-COSMIC and hicolor namespaces,
- mention in desktop integration docs,
- package validation coverage.

The implementation is also checked by running the shell scripts with `--help` or non-mutating modes where possible.
