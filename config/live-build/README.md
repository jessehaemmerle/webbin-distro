# live-build configuration (Ubuntu mode)

This directory is the live-build skeleton for the Aptura OS live ISO. It is copied
to `build/live-build` by `scripts/build-iso.sh`, which then injects:

- Package lists from `package-lists/`.
- The local Aptura APT repository (custom `.deb` packages + custom kernel) as a
  chroot archive source.
- Chroot hooks from the top-level `hooks/` directory.
- Calamares configuration and branding from `installer/`.
- Rendered branding assets from `build/branding`.

live-build is configured for **Ubuntu** with:

```bash
lb config \
  --mode ubuntu \
  --distribution noble \
  --archive-areas "main restricted universe multiverse" \
  --architectures amd64 \
  --linux-flavours none \
  --bootappend-live "boot=live components quiet splash"
```

`--linux-flavours none` is used because Aptura ships its **own kernel** package
from the local repository instead of an archive kernel flavour. See
`docs/kernel.md`.

Subdirectories:

- `config/package-lists/` — chroot package selection.
- `config/archives/` — additional APT sources active during the chroot build
  (Ubuntu backports, and the local Aptura repo wired in at build time).
- `config/hooks/normal/` — late chroot hooks (most logic lives in top-level
  `hooks/`, which the build copies in here).
- `config/includes.chroot/` — files copied verbatim into the live filesystem.
