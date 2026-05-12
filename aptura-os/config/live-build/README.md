# live-build Template

This directory is the editable live-build template. `scripts/build-iso.sh` copies
`config/live-build/config` into `build/live-build/config`, injects generated
package lists, Aptura `.deb` packages, Calamares configuration, and hooks, then
runs `lb config` and `lb build` from the build directory.

Keep this directory small and reviewable. Generated artifacts belong in `build/`.

Important live-build concepts used here:

- `config/package-lists/*.list.chroot` installs packages into the live system.
- `config/packages.chroot/*.deb` installs local Debian packages.
- `config/hooks/normal/*.hook.chroot` runs customization scripts inside chroot.
- `config/includes.chroot/` copies files into the live filesystem.
- `config/includes.binary/` can later be used for boot media files.

TODO:

- Add signed archive key handling for the Aptura public update repository.
- Add arm64 bootloader templates after a tested arm64 build host exists.
- Add reproducible build pinning and snapshot mirror support.
