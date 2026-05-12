# Aptura Settings Center

The settings center starts as part of the Aptura Flow prototype and should later
become a native system app.

Planned sections:

- Network and VPN
- Bluetooth
- Appearance
- Workspaces
- Power
- Updates
- Privacy
- Security
- Region and language
- Keyboard and touchpad

Security model:

- Read-only system state can be exposed through unprivileged D-Bus services.
- Administrative actions must go through PolicyKit.
- No settings module may silently add external accounts or telemetry.
