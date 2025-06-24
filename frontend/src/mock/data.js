// Mock data for Arch ISO Builder
export const mockPackageCategories = [
  {
    id: 'base',
    name: 'Base System',
    description: 'Essential packages for Arch Linux',
    packages: [
      { name: 'base', description: 'Minimal package set to define a basic Arch Linux installation', selected: true, required: true },
      { name: 'base-devel', description: 'Basic tools to build Arch Linux packages', selected: false },
      { name: 'linux', description: 'The Linux kernel and modules', selected: true, required: true },
      { name: 'linux-firmware', description: 'Firmware files for Linux', selected: true, required: true },
      { name: 'grub', description: 'GNU GRand Unified Bootloader', selected: true, required: true },
      { name: 'efibootmgr', description: 'Linux user-space application to modify the EFI Boot Manager', selected: false },
      { name: 'networkmanager', description: 'Network connection manager and user applications', selected: false },
      { name: 'sudo', description: 'Give certain users the ability to run commands as root', selected: false },
      { name: 'nano', description: 'Simple text editor', selected: false },
      { name: 'vim', description: 'Vi Improved text editor', selected: false },
    ]
  },
  {
    id: 'bootloader',
    name: 'Bootloaders & Boot Management',
    description: 'Boot management and bootloader packages',
    packages: [
      { name: 'systemd-boot', description: 'Simple UEFI boot manager', selected: false },
      { name: 'refind', description: 'rEFInd boot manager', selected: false },
      { name: 'os-prober', description: 'Utility to detect other OSes on a set of drives', selected: false },
    ]
  },
  {
    id: 'desktop',
    name: 'Desktop Environments',
    description: 'Graphical desktop environments',
    packages: [
      { name: 'gnome', description: 'GNOME Desktop Environment', selected: false },
      { name: 'kde-plasma', description: 'KDE Plasma Desktop', selected: false },
      { name: 'xfce4', description: 'Lightweight desktop environment', selected: false },
      { name: 'lxde-gtk3', description: 'Lightweight X11 Desktop Environment', selected: false },
      { name: 'mate', description: 'Traditional desktop environment', selected: false },
      { name: 'cinnamon', description: 'Linux Mint desktop environment', selected: false },
    ]
  },
  {
    id: 'windowmanagers',
    name: 'Window Managers',
    description: 'Lightweight window managers for advanced users',
    packages: [
      { name: 'i3-wm', description: 'Tiling window manager', selected: false },
      { name: 'awesome', description: 'Highly configurable window manager', selected: false },
      { name: 'bspwm', description: 'Binary space partitioning window manager', selected: false },
      { name: 'openbox', description: 'Highly configurable window manager', selected: false },
      { name: 'dwm', description: 'Dynamic window manager', selected: false },
      { name: 'qtile', description: 'Tiling window manager written in Python', selected: false },
    ]
  },
  {
    id: 'development',
    name: 'Development Tools',
    description: 'Programming and development packages',
    packages: [
      { name: 'git', description: 'Fast distributed version control system', selected: false },
      { name: 'code', description: 'Visual Studio Code', selected: false },
      { name: 'docker', description: 'Container platform', selected: false },
      { name: 'nodejs', description: 'JavaScript runtime', selected: false },
      { name: 'npm', description: 'Node.js package manager', selected: false },
      { name: 'python', description: 'Python programming language', selected: false },
      { name: 'python-pip', description: 'Python package installer', selected: false },
      { name: 'go', description: 'Go programming language', selected: false },
      { name: 'rust', description: 'Rust programming language', selected: false },
      { name: 'jdk-openjdk', description: 'OpenJDK Java development kit', selected: false },
      { name: 'gcc', description: 'GNU Compiler Collection', selected: false },
      { name: 'make', description: 'GNU make utility', selected: false },
    ]
  },
  {
    id: 'multimedia',
    name: 'Multimedia',
    description: 'Audio, video, and graphics packages',
    packages: [
      { name: 'vlc', description: 'Multi-platform media player', selected: false },
      { name: 'gimp', description: 'GNU Image Manipulation Program', selected: false },
      { name: 'audacity', description: 'Audio editor and recorder', selected: false },
      { name: 'obs-studio', description: 'Video recording and streaming', selected: false },
      { name: 'blender', description: '3D creation suite', selected: false },
      { name: 'inkscape', description: 'Vector graphics editor', selected: false },
      { name: 'kdenlive', description: 'Video editor', selected: false },
      { name: 'mpv', description: 'Media player', selected: false },
    ]
  },
  {
    id: 'gaming',
    name: 'Gaming',
    description: 'Gaming-related packages',
    packages: [
      { name: 'steam', description: 'Gaming platform', selected: false },
      { name: 'lutris', description: 'Gaming client', selected: false },
      { name: 'discord', description: 'Voice and text chat for gamers', selected: false },
      { name: 'nvidia', description: 'NVIDIA proprietary drivers', selected: false },
      { name: 'nvidia-utils', description: 'NVIDIA utilities', selected: false },
      { name: 'lib32-nvidia-utils', description: '32-bit NVIDIA utilities', selected: false },
      { name: 'wine', description: 'Windows compatibility layer', selected: false },
      { name: 'winetricks', description: 'Script to install Windows components', selected: false },
    ]
  },
  {
    id: 'internet',
    name: 'Internet & Communication',
    description: 'Web browsers and communication tools',
    packages: [
      { name: 'firefox', description: 'Mozilla Firefox web browser', selected: false },
      { name: 'chromium', description: 'Open-source web browser', selected: false },
      { name: 'thunderbird', description: 'Email client', selected: false },
      { name: 'telegram-desktop', description: 'Telegram messaging app', selected: false },
      { name: 'wget', description: 'Network utility to retrieve files from HTTP/HTTPS/FTP', selected: false },
      { name: 'curl', description: 'Command line tool for transferring data', selected: false },
    ]
  },
  {
    id: 'office',
    name: 'Office & Productivity',
    description: 'Office suites and productivity applications',
    packages: [
      { name: 'libreoffice-fresh', description: 'LibreOffice office suite', selected: false },
      { name: 'libreoffice-still', description: 'LibreOffice stable version', selected: false },
      { name: 'onlyoffice-bin', description: 'ONLYOFFICE office suite', selected: false },
      { name: 'krita', description: 'Digital painting application', selected: false },
    ]
  },
  {
    id: 'system',
    name: 'System Utilities',
    description: 'System monitoring and utility packages',
    packages: [
      { name: 'htop', description: 'Interactive process viewer', selected: false },
      { name: 'neofetch', description: 'System information tool', selected: false },
      { name: 'tree', description: 'Directory listing in tree format', selected: false },
      { name: 'zip', description: 'Create and extract ZIP archives', selected: false },
      { name: 'unzip', description: 'Extract ZIP archives', selected: false },
      { name: 'p7zip', description: '7-Zip file archiver', selected: false },
      { name: 'rsync', description: 'File synchronization tool', selected: false },
    ]
  }
];

export const mockProfiles = [
  {
    id: 'custom',
    name: 'Custom Configuration',
    description: 'Start from scratch and choose exactly what you need',
    icon: '🛠️',
    packages: ['base', 'linux', 'linux-firmware', 'grub'] // Only essential required packages
  },
  {
    id: 'minimal',
    name: 'Minimal Installation',
    description: 'Bare minimum packages for a functional Arch system',
    icon: '📦',
    packages: ['base', 'base-devel', 'linux', 'linux-firmware', 'grub', 'efibootmgr', 'networkmanager', 'sudo']
  },
  {
    id: 'desktop',
    name: 'Desktop Workstation',
    description: 'Complete desktop environment with common applications',
    icon: '🖥️',
    packages: ['base', 'base-devel', 'linux', 'linux-firmware', 'grub', 'efibootmgr', 'gnome', 'firefox', 'libreoffice-fresh', 'git', 'vim']
  },
  {
    id: 'developer',
    name: 'Developer Setup',
    description: 'Development tools and programming environments',
    icon: '👨‍💻',
    packages: ['base', 'base-devel', 'linux', 'linux-firmware', 'grub', 'efibootmgr', 'i3-wm', 'git', 'vim', 'code', 'docker', 'nodejs', 'python', 'go']
  },
  {
    id: 'gaming',
    name: 'Gaming Rig',
    description: 'Optimized for gaming with graphics drivers and gaming tools',
    icon: '🎮',
    packages: ['base', 'base-devel', 'linux', 'linux-firmware', 'grub', 'efibootmgr', 'kde-plasma', 'steam', 'lutris', 'discord', 'nvidia']
  },
  {
    id: 'server',
    name: 'Server Installation',
    description: 'Headless server setup with essential services',
    icon: '🖧',
    packages: ['base', 'base-devel', 'linux', 'linux-firmware', 'grub', 'efibootmgr', 'openssh', 'nginx', 'docker', 'git']
  }
];

export const mockDesktopEnvironments = [
  {
    id: 'none',
    name: 'No Desktop Environment',
    description: 'Command line only',
    selected: true
  },
  {
    id: 'gnome',
    name: 'GNOME',
    description: 'Modern, easy-to-use desktop environment',
    selected: false
  },
  {
    id: 'kde',
    name: 'KDE Plasma',
    description: 'Feature-rich and customizable desktop',
    selected: false
  },
  {
    id: 'xfce',
    name: 'XFCE',
    description: 'Lightweight, fast desktop environment',
    selected: false
  },
  {
    id: 'i3',
    name: 'i3 Window Manager',
    description: 'Tiling window manager for advanced users',
    selected: false
  }
];

export const mockUserConfig = {
  hostname: 'archbox',
  username: 'user',
  password: '',
  rootPassword: '',
  timezone: 'UTC',
  locale: 'en_US.UTF-8',
  keymap: 'us'
};

export const mockISOConfigs = [
  {
    id: '1',
    name: 'My Gaming Rig',
    profile: 'gaming',
    createdAt: '2025-01-08T10:30:00Z',
    status: 'completed',
    size: '2.1 GB',
    downloadUrl: '/downloads/gaming-rig.iso'
  },
  {
    id: '2',
    name: 'Development Environment',
    profile: 'developer',
    createdAt: '2025-01-08T09:15:00Z',
    status: 'building',
    progress: 75
  },
  {
    id: '3',
    name: 'Minimal Server',
    profile: 'server',
    createdAt: '2025-01-07T16:45:00Z',
    status: 'completed',
    size: '850 MB',
    downloadUrl: '/downloads/minimal-server.iso'
  }
];