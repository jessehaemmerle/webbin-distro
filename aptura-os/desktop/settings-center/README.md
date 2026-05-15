# Aptura Settings Center

The settings center is a future native system app idea. For the MVP, Aptura OS
uses upstream System Settings instead of a custom settings shell.

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
