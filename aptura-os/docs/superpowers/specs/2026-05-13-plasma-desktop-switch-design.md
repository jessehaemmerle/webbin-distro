# Aptura Plasma Desktop Switch Design

## Goal

Switch Aptura OS from the current System76 COSMIC desktop stack to KDE Plasma while preserving the existing Aptura branding work: logos, colors, wallpapers, Calamares branding, Plymouth theme, desktop launchers, and local Aptura tools.

The visible edition name should become Plasma instead of COSMIC. Branding should continue to feel like Aptura, not a generic KDE remix.

## Scope

- Replace COSMIC runtime packages with KDE Plasma packages in the live image package list, `aptura-desktop`, and `aptura-meta`.
- Replace COSMIC Greeter and `greetd` session setup with SDDM and Plasma session defaults.
- Remove the temporary COSMIC OBS package source and related APT pinning from build and package settings.
- Update Calamares display manager configuration for SDDM and Plasma.
- Update visible identity strings from COSMIC to Plasma in build config, branding config, os-release metadata, MOTD, About dialog, installer branding text, and validation docs/tests.
- Preserve existing Aptura assets and utility launchers, including current wallpaper choices, icon assets, Plymouth branding, Calamares stylesheet, and Aptura desktop tools.

## Out of Scope

- Redesigning the Aptura visual identity.
- Replacing existing Aptura wallpapers or icons with new artwork.
- Creating a full KDE theme package beyond applying existing Aptura defaults where the current repository already has hooks or settings.
- Building or validating a full ISO in this change unless the local environment already supports it cheaply.

## Package Design

The default desktop stack should use Debian KDE Plasma packages rather than the external COSMIC archive.

Core desktop packages:

- `kde-plasma-desktop`
- `plasma-workspace`
- `sddm`
- `systemsettings`
- `dolphin`
- `konsole`
- `kate`
- `ark`
- `kde-spectacle`
- `plasma-discover`
- `xdg-desktop-portal-kde`

Existing workstation packages such as Firefox ESR, Flatpak, Synaptic, firmware tools, backup tools, printer/scanner support, diagnostics, and power profiles should remain.

COSMIC packages, COSMIC portal packages, COSMIC Greeter, and `greetd` should be removed from the default dependency surface.

## Session And Installer Design

The live and installed systems should default to Plasma through SDDM.

Calamares `displaymanager.conf` should list `sddm` and set the default desktop environment to the Plasma session. Any live-config hook that only configures COSMIC Greeter should be removed or replaced with a small SDDM-oriented hook only if needed by the existing live-build flow.

Installer modules that enable display manager services should enable SDDM instead of COSMIC Greeter or `greetd`.

## Branding Design

Existing Aptura visual assets stay in place. Text and metadata that identify the edition should change from COSMIC to Plasma:

- `Aptura OS 0.1.4 Adeline Plasma`
- `Aptura Plasma`
- `VARIANT="Plasma"`
- `VARIANT_ID=plasma`
- `DEFAULT_MODE="plasma"`

Theme or icon directories currently named `Aptura-COSMIC` may remain temporarily if renaming them would risk breaking already-installed asset references. Their user-facing comments should be changed where practical, and future cleanup can rename the theme namespace in a dedicated migration.

## Testing And Validation

Update repository tests and validation scripts so they expect:

- Plasma and SDDM packages instead of COSMIC and `greetd`.
- `xdg-desktop-portal-kde` instead of `xdg-desktop-portal-cosmic`.
- Plasma edition metadata.
- Existing Aptura branding files and desktop utilities still present.

Run the available shell validation tests after implementation. If full ISO build validation is not practical locally, document that as remaining manual verification.
