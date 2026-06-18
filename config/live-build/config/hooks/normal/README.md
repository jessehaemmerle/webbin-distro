# live-build normal hooks

`scripts/build-iso.sh` copies the executable hooks from the repository's
top-level `hooks/` directory into this folder (named `0xx-*.hook.chroot`) so
they run inside the chroot in numeric order during image construction.

Keep the canonical hook sources in `hooks/` — do not edit copies here.
