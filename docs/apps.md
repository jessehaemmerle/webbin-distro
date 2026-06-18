# Everyday applications

Aptura targets daily work: office, mail, web, music, plus the supporting tools a
desktop needs. Defaults live in the `aptura-apps` metapackage and a build hook.

| Need        | Default                | Delivery                              |
|-------------|------------------------|---------------------------------------|
| Office      | LibreOffice            | APT (`aptura-apps`)                    |
| Mail        | Thunderbird            | APT (`aptura-apps`)                    |
| Browser     | Firefox                | **Mozilla APT `.deb`** (not snap)     |
| Music       | Spotify                | Flatpak (first-boot install hook)     |
| App store   | GNOME Software         | APT + Flatpak/Flathub plugin          |
| Backups     | Déjà Dup               | APT                                    |
| Snapshots   | Timeshift              | APT (recommended)                     |
| Codecs      | GStreamer plugins      | APT                                    |
| Printing    | CUPS + config tool     | APT                                    |
| Firmware    | fwupd                  | APT                                    |

## Firefox as a real `.deb`

Ubuntu ships Firefox only as a snap (a transitional `.deb` that pulls snapd). To
keep Aptura snap-free, the build configures the Mozilla APT repository and pins
it above Ubuntu (`config/live-build/config/archives/mozilla.list.chroot` +
`.../preferences.d/mozilla-firefox`). `build-iso.sh` fetches the Mozilla signing
key on the Linux host. `firefox` then resolves to Mozilla's `.deb`.

## Spotify

Spotify is not in APT. The `050-flatpak-apps.sh` hook adds Flathub and installs
`com.spotify.Client` on first boot (a oneshot systemd unit that self-disables).
This avoids shipping proprietary bits in the ISO and works once the user has a
network connection.

## Snap vs Flatpak

`PREFER_FLATPAK_OVER_SNAP=true` removes snapd during the build and pins it out,
standardising on Flatpak/Flathub for sandboxed apps. Set it to `false` to keep
snap available.
