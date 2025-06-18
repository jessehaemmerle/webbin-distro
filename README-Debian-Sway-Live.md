# Debian Sway Live System

Ein modernes, leichtgewichtiges Debian-Live-System mit Sway Tiling Window Manager und deutscher Lokalisierung.

## Überblick

Dieses Projekt erstellt ein bootfähiges Debian-Live-System basierend auf Debian bookworm (stable) mit:

- **Sway** - Wayland-basierter Tiling Window Manager
- **Deutsche Lokalisierung** - Sprache, Tastaturlayout (DE), Zeitzone (Europe/Vienna)
- **Moderne Tools** - Waybar, Foot Terminal, Mako Notifications
- **Vollständige Desktop-Umgebung** - Web-Browser, Dateimanager, Entwicklungstools

## Systemanforderungen

### Zum Erstellen des Live-Systems:
- Debian bookworm (oder kompatible Distribution)
- Mindestens 4GB freier Speicherplatz
- Root-Zugriff
- Internetverbindung

### Zum Ausführen des Live-Systems:
- ARM64-kompatible Hardware
- Mindestens 2GB RAM
- USB-Stick oder DVD für das Live-System

## Erstellung des Live-Systems

### 1. Abhängigkeiten installieren

```bash
sudo apt update
sudo apt install -y live-build live-config live-boot debootstrap
```

### 2. Build-Script ausführen

```bash
sudo ./build-debian-sway-live.sh
```

Das Script durchläuft folgende Phasen:
1. **Bootstrap** - Grundsystem herunterladen
2. **Chroot** - Pakete installieren und konfigurieren
3. **Installer** - Debian-Installer vorbereiten
4. **Binary** - ISO-Image erstellen

Die Erstellung dauert je nach Hardware 30-60 Minuten.

### 3. ISO-Image verwenden

Nach erfolgreichem Build finden Sie die ISO-Datei:
- `live-image-arm64.hybrid.iso` - Original-Dateiname
- `debian-sway-live-YYYYMMDD.iso` - Benutzerfreundlicher Name

## Installation auf USB-Stick

```bash
# USB-Gerät identifizieren (z.B. /dev/sdb)
lsblk

# ISO auf USB-Stick schreiben (VORSICHT: Alle Daten auf dem Stick gehen verloren!)
sudo dd if=debian-sway-live-YYYYMMDD.iso of=/dev/sdX bs=4M status=progress
```

## Verwendung des Live-Systems

### Start
1. USB-Stick einlegen und von USB booten
2. Automatischer Login als Benutzer `user` (Passwort: `live`)
3. Sway startet automatisch

### Wichtige Tastenkombinationen

| Tastenkombination | Aktion |
|------------------|--------|
| `Super + Return` | Terminal öffnen |
| `Super + d` | Anwendungsstarter |
| `Super + Shift + q` | Fenster schließen |
| `Super + f` | Vollbild |
| `Super + 1-0` | Arbeitsbereich wechseln |
| `Super + Shift + 1-0` | Fenster zu Arbeitsbereich verschieben |
| `Super + h/j/k/l` | Fokus bewegen (Vim-Style) |
| `Super + Shift + h/j/k/l` | Fenster verschieben |
| `Super + b` | Horizontale Teilung |
| `Super + v` | Vertikale Teilung |
| `Super + s` | Stapel-Layout |
| `Super + w` | Tab-Layout |
| `Super + e` | Layout wechseln |
| `Super + Shift + w` | Chromium öffnen |
| `Super + Shift + f` | Dateimanager öffnen |
| `Print` | Screenshot |
| `Super + Print` | Bereich-Screenshot |

### Anwendungen

#### Vorinstallierte Software:
- **Web-Browser**: Chromium, Firefox ESR
- **Terminal**: Foot (mit Nord-Theme)
- **Dateimanager**: Thunar
- **Texteditor**: Nano, Micro, Gedit
- **Mediaplayer**: MPV
- **PDF-Viewer**: Zathura
- **Taschenrechner**: Galculator
- **Systemtools**: htop, btop, neofetch, inxi

#### Entwicklungstools:
- Git, Python3, Node.js, npm
- Build-essential, CMake
- JetBrains Mono Font, Fira Code

#### System-Utilities:
- Network Manager (GUI)
- PulseAudio/PipeWire
- Disk Utility, GParted
- Hardware-Informationen

## Systemkonfiguration

### Sway-Konfiguration
- Datei: `~/.config/sway/config`
- Nord-Farbschema
- Deutsche Tastatur (DE, nodeadkeys)
- Automatischer Start von Waybar, Mako, Terminal

### Waybar-Konfiguration
- Datei: `~/.config/waybar/config` und `~/.config/waybar/style.css`
- Zeigt Arbeitsbereiche, Fenster, System-Info
- CPU, RAM, Temperatur, Batterie, Netzwerk, Audio

### Terminal-Konfiguration (Foot)
- Datei: `~/.config/foot/foot.ini`
- Nord-Farbschema
- JetBrains Mono Font
- Deutsche Tastenkombinationen

### Benachrichtigungen (Mako)
- Datei: `~/.config/mako/config`
- Nord-Farbschema
- Position: oben rechts
- Gruppierung nach Zusammenfassung

## Lokalisierung

- **Sprache**: Deutsch (de_DE.UTF-8)
- **Tastatur**: Deutsch (DE, nodeadkeys)
- **Zeitzone**: Europe/Vienna
- **Alt+Shift**: Layout-Umschaltung (falls mehrere konfiguriert)

## System-Installation

Das Live-System kann auch auf die Festplatte installiert werden:

1. `Install Debian Sway` aus dem Anwendungsmenü starten
2. Oder Terminal: `sudo calamares`
3. Installationsassistent folgen

## Anpassung und Entwicklung

### Projekt-Struktur

```
debian-sway-live/
├── config/
│   ├── package-lists/          # Paketlisten
│   │   ├── wayland-sway.list.chroot
│   │   ├── localization.list.chroot
│   │   └── installer.list.chroot
│   ├── includes.chroot/        # Dateien für das Live-System
│   │   ├── etc/               # Systemkonfiguration
│   │   ├── home/user/         # Benutzerkonfiguration
│   │   └── usr/share/         # Zusätzliche Dateien
│   └── hooks/                 # Build-Hooks
│       └── live/              # Live-System-Hooks
```

### Eigene Anpassungen

1. **Zusätzliche Pakete**: Bearbeiten Sie die `.list.chroot` Dateien
2. **Konfigurationen**: Ändern Sie Dateien in `config/includes.chroot/`
3. **Scripts**: Anpassen der Hooks in `config/hooks/live/`
4. **Wallpaper**: Ersetzen Sie `/usr/share/backgrounds/debian-sway-wallpaper.jpg`

### Neues Build erstellen

Nach Änderungen:

```bash
cd /app/debian-sway-live
sudo lb clean --all
sudo ./build-debian-sway-live.sh
```

## Fehlerbehebung

### Build-Probleme

1. **Speicherplatz**: Mindestens 4GB freier Speicher erforderlich
2. **Berechtigungen**: Als root ausführen
3. **Netzwerk**: Stabile Internetverbindung für Paket-Downloads
4. **Clean Build**: Bei Problemen `lb clean --all` ausführen

### Laufzeit-Probleme

1. **Sway startet nicht**: 
   - Terminal: `Ctrl+Alt+F2`, dann `startx` oder `sway`
   - Logs: `journalctl -u sway` oder `~/.local/share/sway/sway.log`

2. **Netzwerk**: 
   - `nmtui` im Terminal für Netzwerkkonfiguration
   - Oder `nm-connection-editor` für GUI

3. **Audio**: 
   - `pavucontrol` für Audio-Einstellungen
   - `pulseaudio --start` falls nötig

## Technische Details

- **Distribution**: Debian bookworm (stable)
- **Architektur**: ARM64
- **Kernel**: Linux (generic)
- **Init-System**: systemd
- **Display-Server**: Wayland
- **Window Manager**: Sway
- **Audio**: PulseAudio/PipeWire
- **Netzwerk**: NetworkManager

## Lizenz

Dieses Projekt basiert auf Debian und verwendet ausschließlich Open-Source-Software. Die Konfigurationsdateien und Scripts stehen unter MIT-Lizenz zur Verfügung.

## Mitwirkende

Erstellt mit live-build für eine moderne, deutsche Sway-Desktop-Erfahrung.

---

**Viel Spaß mit Ihrem neuen Debian Sway Live System! 🚀**