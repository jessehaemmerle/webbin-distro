# Package Management

## APT Model

Aptura OS uses APT and Debian-compatible `.deb` packages.

Repository layers:

1. Debian Stable base repositories.
2. Debian security repository.
3. Aptura local repository during development.
4. Aptura signed public repository for production.

## Package Lists

`config/packages.list` defines the default live image packages.

Keep the list readable:

- One package per line.
- Comments allowed.
- Prefer metapackages for Aptura-owned defaults.
- Avoid edition-specific packages in the base list.

## Custom Packages

Custom package source lives in `packages/`.

Build:

```bash
./scripts/build-packages.sh
```

Output:

```text
build/packages/*.deb
```

## Local Repository

Create:

```bash
./scripts/create-local-repo.sh
```

Output:

```text
build/localrepo/
```

The repository contains `Packages`, `Packages.gz`, and `Release` metadata.

## Signing

Enable in `config/distro.env`:

```bash
SIGN_REPO="true"
REPO_GPG_KEY_ID="YOURKEYID"
```

Then run:

```bash
./scripts/sign-repo.sh
```

Production repository entries should use:

```text
deb [signed-by=/usr/share/keyrings/aptura-archive-keyring.gpg] https://repo.aptura.local/aptura trixie main
```

Do not use `trusted=yes` in production.

## Versioning

Recommended package versions:

- Native Aptura packages: `0.1.0`, `0.1.1`, `0.2.0`
- Debian-derived modified packages: `<upstream-version>-<debian-revision>aptura1`
- Backports: include suite marker in changelog and repository channel

Every package update needs:

- `debian/changelog` entry.
- Source control tag or CI build ID.
- Rebuild in a clean environment.

## Updates

Production update flow:

1. Build `.deb` packages.
2. Run package tests.
3. Publish to staging repo.
4. Run VM upgrade tests.
5. Sign and promote to stable repo.
6. Update release notes.

For critical security updates, Aptura should prefer fast promotion with scoped
testing over holding Debian security fixes.

## External Repositories

External repositories must:

- Use HTTPS or a trusted transport.
- Use signed metadata.
- Store keys in `/usr/share/keyrings`.
- Be documented in release notes.
- Be pinned when they can replace core packages.

Avoid PPAs or third-party repos in the default ISO unless there is a clear
maintenance owner and a security review.
