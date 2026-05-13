# Aptura Installer

Aptura OS uses Calamares as the graphical installer for the MVP.

Why Calamares:

- Distribution-neutral installer framework.
- Mature modules for locale, keyboard, timezone, partitioning, users, bootloader, and summary/finish screens.
- Good fit for Debian live images when paired with careful module configuration.
- Lets Aptura focus on distribution identity and desktop UX instead of writing a disk installer from scratch.

Configured flow:

1. Welcome
2. Locale
3. Keyboard
4. Timezone
5. Partitioning
6. User creation
7. Summary
8. Partition execution
9. Mount
10. Unpack live filesystem
11. Configure fstab, locale, keyboard, users, services, display manager, GRUB, and bootloader
12. Remove live-only packages and rebuild encrypted-boot initramfs support
13. Unmount
14. Finish

Partitioning risks:

- Whole-disk installation deletes existing data.
- Encryption must be tested across BIOS and UEFI paths.
- Bootloader installation can fail when the VM or hardware boot mode does not match the partition layout.
- Encrypted installs need the Calamares LUKS keyfile, grubcfg, and initramfs jobs in sequence.

Testing:

- Boot the ISO in QEMU with a disposable virtual disk.
- Test both BIOS and UEFI boot paths.
- Test automatic partitioning, manual partitioning, and encrypted install.
- Reboot after installation and verify APT sources, user sudo access, AppArmor, and branding.

TODO:

- Add an OEM/preinstall mode using Calamares' OEM flow or a separate first-boot wizard.
- Verify `unpackfs.conf` against the final Debian live-build filesystem path.
- Add Btrfs subvolume policy if Aptura adopts Btrfs as an option.
- Add Secure Boot enrollment and shim signing design after release keys exist.
