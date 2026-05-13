# Security

## Threat Model

Assets:

- User files and credentials.
- APT trust chain.
- Installer disk operations.
- Bootloader and kernel integrity.
- Local system settings and privileged actions.
- User privacy.

Attackers:

- Network attacker intercepting package downloads.
- Malicious or compromised third-party repository.
- Local unprivileged user attempting privilege escalation.
- Malicious application inside the desktop session.
- Physical attacker with disk access.
- Mistaken user action during partitioning.

Assumptions:

- Debian archive signing keys are trusted.
- Aptura release keys are generated and protected before public releases.
- The user verifies ISO checksums/signatures for production images.
- Physical attacks without disk encryption are not fully mitigated.

## Default Hardening

MVP defaults:

- No SSH server enabled by default.
- Root account locked.
- Administrative user uses `sudo`.
- AppArmor installed and enabled when available.
- UFW installed and configured to deny incoming traffic, but not forcibly enabled in the live session.
- APT rejects unauthenticated and insecure repositories.
- Unattended security updates are available but opt-in for the desktop MVP.
- No telemetry.
- No external cloud accounts or online assistant by default.
- Plasma privacy defaults should avoid telemetry, cloud accounts, and unnecessary recent-file exposure.

## Package Source Security

APT requirements:

- Use Debian repository signatures.
- Use Aptura repository signatures before distributing updates.
- Do not use `trusted=yes` for production repositories.
- Do not allow unsigned repositories.
- Prefer codename suites like `trixie`, not moving aliases like `stable`.
- Store third-party keys in `/usr/share/keyrings` and reference them with `Signed-By`.

External repositories:

- Must be documented.
- Must be signed.
- Must be narrowly scoped with APT pinning when possible.
- Must not replace core Debian packages without review.

## Update Process

Recommended production update flow:

1. Build Aptura packages in CI.
2. Sign packages or repository metadata with protected release keys.
3. Publish to staging repository.
4. Run VM upgrade tests.
5. Promote to stable repository.
6. Publish release notes.

Security updates from Debian should be available quickly. Aptura should avoid
blocking Debian security updates unless a regression is known and documented.

## Rights Model

User session:

- Normal user has no root privileges without sudo/PolicyKit.
- Desktop UI must not run as root.
- Privileged actions go through PolicyKit.

System services:

- Keep D-Bus APIs narrow.
- Validate all caller input.
- Avoid shelling out with unsanitized strings.
- Log administrative changes.

Polkit:

- `aptura-settings` currently keeps sudo as the admin group.
- Future custom rules must be specific to action IDs.
- Broad passwordless admin rules are not allowed.

## Network Services

Default desktop ISO:

- SSH disabled.
- No server daemons enabled unless required for desktop hardware.
- NetworkManager enabled.
- Bluetooth enabled for desktop usability but should be auditable and disableable.

Future editions may enable additional services only through explicit profiles.

## Installer Security

Calamares runs privileged operations. Risks:

- Data loss during partitioning.
- Incorrect bootloader target.
- Encryption misconfiguration.
- Copying live user state into installed system.

Mitigations:

- Clear summary screen.
- VM test matrix.
- No automatic cloud login.
- Review generated `/etc/fstab`, users, sudoers, and bootloader configuration.

## Secure Boot Concept

MVP status: documented, not implemented.

Production plan:

- Use shim where legally and operationally appropriate.
- Sign GRUB and kernel artifacts with protected keys.
- Document Machine Owner Key enrollment for custom builds.
- Publish key fingerprints.
- Test revocation and upgrade paths.

## Disk Encryption

Calamares partitioning enables LUKS automated partitioning in the template.
Production release testing must verify:

- Passphrase prompt at boot.
- UEFI and BIOS boot paths.
- Resume/swap behavior.
- Recovery documentation.

## Known Open Points

- No public Aptura signing key yet.
- No automated ISO boot test yet.
- No Secure Boot implementation yet.
- No AppArmor profiles for future Aptura-specific services yet.
- Aptura System Check is read-only and local; future privileged integrations still need narrow D-Bus services.
- Calamares configuration needs end-to-end validation on the first real ISO.
