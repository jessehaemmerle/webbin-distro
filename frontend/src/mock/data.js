// Mock data for Arch ISO Builder
export const mockPackageCategories = [
  {
    id: 'base',
    name: 'Base System',
    description: 'Essential packages for Arch Linux',
    packages: [
      { name: 'base', description: 'Minimal package set to define a basic Arch Linux installation', selected: true, required: true },
      { name: 'base-devel', description: 'Basic tools to build Arch Linux packages', selected: true },
      { name: 'linux', description: 'The Linux kernel and modules', selected: true, required: true },
      { name: 'linux-firmware', description: 'Firmware files for Linux', selected: true, required: true },
      { name: 'grub', description: 'GNU GRand Unified Bootloader', selected: true },
      { name: 'efibootmgr', description: 'Linux user-space application to modify the EFI Boot Manager', selected: true },
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
      { name: 'i3-wm', description: 'Tiling window manager', selected: false },
      { name: 'awesome', description: 'Highly configurable window manager', selected: false },
    ]
  },
  {
    id: 'development',
    name: 'Development Tools',
    description: 'Programming and development packages',
    packages: [
      { name: 'git', description: 'Fast distributed version control system', selected: false },
      { name: 'vim', description: 'Vi Improved text editor', selected: false },
      { name: 'code', description: 'Visual Studio Code', selected: false },
      { name: 'docker', description: 'Container platform', selected: false },
      { name: 'nodejs', description: 'JavaScript runtime', selected: false },
      { name: 'python', description: 'Python programming language', selected: false },
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
    ]
  }
];

export const mockProfiles = [
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