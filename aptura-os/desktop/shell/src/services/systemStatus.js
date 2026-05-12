export const apps = [
  { name: "Files", category: "Core", command: "nautilus", color: "#18a999" },
  { name: "Terminal", category: "Core", command: "gnome-terminal", color: "#e66f51" },
  { name: "Browser", category: "Web", command: "firefox-esr", color: "#f0b35a" },
  { name: "Settings", category: "System", command: "gnome-control-center", color: "#5d8aa8" },
  { name: "Installer", category: "System", command: "calamares", color: "#9b6a3d" },
  { name: "Updates", category: "System", command: "aptura-flow --updates", color: "#4f9d69" },
];

export const notifications = [
  { id: 1, title: "Security updates", body: "2 packages ready", tone: "attention", time: "09:20" },
  { id: 2, title: "Network", body: "Aptura-Lab connected", tone: "ok", time: "09:12" },
  { id: 3, title: "Backup reminder", body: "External drive not connected", tone: "neutral", time: "Yesterday" },
];

export const workspaces = [
  { id: 1, name: "Focus", windows: ["Terminal", "Browser"] },
  { id: 2, name: "Design", windows: ["Aptura Flow", "Files"] },
  { id: 3, name: "Review", windows: [] },
];

export const quickActions = [
  { id: "wifi", label: "Wi-Fi", value: "Aptura-Lab", active: true },
  { id: "bluetooth", label: "Bluetooth", value: "On", active: true },
  { id: "vpn", label: "VPN", value: "Off", active: false },
  { id: "theme", label: "Dark Mode", value: "On", active: true },
  { id: "updates", label: "Updates", value: "2 ready", active: true },
  { id: "power", label: "Power", value: "Balanced", active: true },
];

export const updateState = {
  status: "attention",
  available: 2,
  security: 1,
  lastChecked: "Today 09:18",
  channel: "Debian trixie + Aptura local",
};

export const settingsSections = [
  "Network",
  "Bluetooth",
  "Appearance",
  "Workspaces",
  "Power",
  "Updates",
  "Privacy",
  "Security",
];
