# 🛠️ Arch ISO Builder

> **Create custom Arch Linux installation ISOs with your preferred packages, desktop environments, and configurations.**

A modern, full-stack web application that simplifies the process of creating custom Arch Linux installation ISOs. Built with React frontend and FastAPI backend, providing an intuitive interface for both beginners and advanced users.

![Arch ISO Builder](https://img.shields.io/badge/React-18+-blue) ![FastAPI](https://img.shields.io/badge/FastAPI-Latest-green) ![MongoDB](https://img.shields.io/badge/MongoDB-Latest-brightgreen) ![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ Features

### 🎯 **Profile-Based Configuration**
- **Custom Configuration**: Complete control over package selection
- **Minimal Installation**: Essential packages only
- **Desktop Workstation**: Full desktop with common applications
- **Developer Setup**: Programming tools and environments
- **Gaming Rig**: Optimized for gaming with drivers
- **Server Installation**: Headless server configuration

### 📦 **Advanced Package Management**
- **10+ Package Categories**: Base System, Development Tools, Gaming, Multimedia, etc.
- **Smart Search & Filtering**: Find packages quickly with real-time search
- **Required Package Protection**: Essential packages cannot be deselected
- **Real-time Package Counter**: Track selections with live updates

### 🖥️ **Desktop Environment Support**
- GNOME - Modern, user-friendly interface
- KDE Plasma - Feature-rich and customizable
- XFCE - Lightweight and fast
- i3 Window Manager - For tiling window management
- Command Line Only - Minimal server setup

### 👤 **User Configuration**
- Custom hostname and username
- Timezone selection with major options
- Locale configuration (UTF-8 support)
- Keyboard layout selection

### 🚀 **Real-time Build System**
- **Background Processing**: ISOs build without blocking the UI
- **Live Progress Tracking**: Real-time build progress with percentage
- **Build History**: Track all your previous ISO builds
- **Status Management**: Pending, Building, Completed, Failed states
- **Direct Downloads**: One-click download of completed ISOs

### 🎨 **Modern UI/UX**
- **Beautiful Gradients**: Professional purple/slate theme
- **Smooth Animations**: Hover effects and transitions
- **Responsive Design**: Works perfectly on desktop, tablet, and mobile
- **Toast Notifications**: Real-time feedback for all actions
- **Professional Layout**: Intuitive 5-tab navigation

## 🏗️ Architecture

### **Frontend (React 18+)**
```
📁 frontend/
├── 📁 src/
│   ├── 📁 components/
│   │   ├── ArchISOBuilder.jsx     # Main application component
│   │   └── 📁 ui/                 # Reusable UI components
│   ├── 📁 services/
│   │   └── api.js                 # API service layer
│   ├── 📁 hooks/
│   │   └── use-toast.js           # Toast notification hook
│   └── App.js                     # Application root
├── 📁 public/
│   ├── index.html                 # HTML template
│   └── 📁 downloads/              # ISO download directory
└── package.json                   # Dependencies and scripts
```

### **Backend (FastAPI)**
```
📁 backend/
├── server.py                      # Main FastAPI application
├── models.py                      # Pydantic data models
├── database.py                    # MongoDB integration
├── iso_builder.py                 # ISO building logic
├── requirements.txt               # Python dependencies
└── .env                          # Environment configuration
```

## 🚀 Quick Start

### **Prerequisites**
- Docker & Docker Compose
- Node.js 18+ (for development)
- Python 3.8+ (for development)
- MongoDB (included in Docker setup)

### **1. Clone the Repository**
```bash
git clone <repository-url>
cd arch-iso-builder
```

### **2. Environment Setup**
```bash
# Frontend environment
cat > frontend/.env << EOF
REACT_APP_BACKEND_URL=http://localhost:8001
EOF

# Backend environment  
cat > backend/.env << EOF
MONGO_URL=mongodb://localhost:27017/
DB_NAME=arch_iso_builder
EOF
```

### **3. Start with Docker (Recommended)**
```bash
# Start all services
docker-compose up -d

# Check service status
docker-compose ps
```

### **4. Manual Development Setup**

#### **Backend Setup**
```bash
cd backend
pip install -r requirements.txt
uvicorn server:app --host 0.0.0.0 --port 8001 --reload
```

#### **Frontend Setup**
```bash
cd frontend
yarn install
yarn start
```

### **5. Access the Application**
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8001/api
- **API Documentation**: http://localhost:8001/docs

## 📖 User Guide

### **Step 1: Profile Selection**
1. Open the application in your browser
2. Navigate to the **Profiles** tab
3. Choose from 6 pre-configured profiles:
   - **Custom Configuration**: Start from scratch (advanced users)
   - **Minimal Installation**: Essential packages only
   - **Desktop Workstation**: Complete desktop setup
   - **Developer Setup**: Programming environment
   - **Gaming Rig**: Gaming-optimized configuration
   - **Server Installation**: Headless server setup

### **Step 2: Package Configuration**
1. Go to the **Packages** tab
2. Use the search bar to find specific packages
3. Filter by category (Base System, Development, Gaming, etc.)
4. Check/uncheck packages as needed
5. Required packages (marked in red) cannot be deselected
6. Monitor the package counter in real-time

### **Step 3: Desktop Environment**
1. Switch to the **Desktop** tab
2. Select your preferred desktop environment:
   - **None**: Command line only
   - **GNOME**: Modern, user-friendly
   - **KDE Plasma**: Feature-rich
   - **XFCE**: Lightweight
   - **i3**: Tiling window manager

### **Step 4: User Setup**
1. Open the **User Setup** tab
2. Configure system settings:
   - **Hostname**: Your computer's network name
   - **Username**: Primary user account
   - **Timezone**: Select your location
   - **Locale**: Language and region settings

### **Step 5: Build & Download**
1. Navigate to the **Build** tab
2. Review your configuration summary
3. Click **Build Custom ISO**
4. Monitor build progress in real-time
5. Download completed ISOs with one click
6. Access build history and re-download previous ISOs

## 🔧 API Documentation

### **Profile Management**
```http
GET /api/profiles
# Returns available installation profiles

Response:
[
  {
    "id": "custom",
    "name": "Custom Configuration", 
    "description": "Start from scratch and choose exactly what you need",
    "icon": "🛠️",
    "packages": ["base", "linux", "linux-firmware", "grub"]
  }
]
```

### **Package Categories**
```http
GET /api/packages
# Returns package categories and individual packages

Response:
[
  {
    "id": "base",
    "name": "Base System",
    "description": "Essential packages for Arch Linux",
    "packages": [
      {
        "name": "base",
        "description": "Minimal package set to define a basic Arch Linux installation",
        "selected": true,
        "required": true
      }
    ]
  }
]
```

### **ISO Configuration**
```http
POST /api/iso-configs
# Create new ISO configuration

Request Body:
{
  "name": "My Custom ISO",
  "profile_id": "desktop",
  "selected_packages": ["base", "linux", "gnome", "firefox"],
  "desktop_environment": "gnome",
  "user_config": {
    "hostname": "archbox",
    "username": "user",
    "timezone": "UTC",
    "locale": "en_US.UTF-8"
  }
}

Response:
{
  "id": "uuid-here",
  "name": "My Custom ISO",
  "status": "pending",
  "progress": 0,
  "created_at": "2025-01-08T12:00:00Z"
}
```

### **Build Status**
```http
GET /api/iso-configs
# Get all ISO configurations with status

GET /api/iso-configs/{id}
# Get specific ISO configuration

GET /api/iso-configs/{id}/logs
# Get build logs for specific configuration
```

### **Download**
```http
GET /api/downloads/{filename}
# Download completed ISO file
```

## 🔨 Development

### **Project Structure**
```
arch-iso-builder/
├── 📁 frontend/           # React application
├── 📁 backend/            # FastAPI server
├── 📁 docs/              # Documentation
├── docker-compose.yml    # Docker services
├── README.md             # This file
└── DEPLOYMENT.md         # Deployment guide
```

### **Technology Stack**
- **Frontend**: React 18, Tailwind CSS, Radix UI, Lucide Icons
- **Backend**: FastAPI, Pydantic, Motor (async MongoDB)
- **Database**: MongoDB
- **Build System**: Custom archiso integration
- **Infrastructure**: Docker, Docker Compose

### **Development Commands**

#### **Frontend**
```bash
# Install dependencies
yarn install

# Start development server
yarn start

# Build for production
yarn build

# Run tests
yarn test
```

#### **Backend**
```bash
# Install dependencies
pip install -r requirements.txt

# Start development server
uvicorn server:app --reload

# Run tests
python -m pytest

# Code formatting
black .
isort .
```

### **Adding New Features**

#### **New Package Category**
1. Update `SAMPLE_PACKAGE_CATEGORIES` in `backend/server.py`
2. Add packages with proper metadata
3. Test the new category in the frontend

#### **New Profile**
1. Add profile to `SAMPLE_PROFILES` in `backend/server.py`
2. Include icon and package list
3. Update frontend profile selection

#### **Custom Build Steps**
1. Modify `iso_builder.py` to add new build phases
2. Update progress tracking
3. Add logging for new steps

## 🚀 Deployment

### **Production Deployment**

#### **1. Server Requirements**
- 4+ GB RAM (for ISO building)
- 20+ GB storage (for ISO files)
- Docker & Docker Compose
- Reverse proxy (nginx/Caddy)

#### **2. Environment Configuration**
```bash
# Production environment
cat > .env.production << EOF
# Frontend
REACT_APP_BACKEND_URL=https://your-domain.com

# Backend
MONGO_URL=mongodb://mongo:27017/
DB_NAME=arch_iso_builder

# Security
JWT_SECRET=your-secure-secret-here
ALLOWED_ORIGINS=https://your-domain.com
EOF
```

#### **3. Docker Production Setup**
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  frontend:
    build: 
      context: ./frontend
      target: production
    environment:
      - REACT_APP_BACKEND_URL=https://your-domain.com
    
  backend:
    build: ./backend
    environment:
      - MONGO_URL=mongodb://mongo:27017/
      - DB_NAME=arch_iso_builder
    volumes:
      - iso_storage:/app/frontend/public/downloads
      
  mongo:
    image: mongo:latest
    volumes:
      - mongo_data:/data/db
      
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ssl_certs:/etc/ssl/certs

volumes:
  mongo_data:
  iso_storage:
  ssl_certs:
```

#### **4. Deploy Commands**
```bash
# Build and start production services
docker-compose -f docker-compose.prod.yml up -d

# Monitor logs
docker-compose -f docker-compose.prod.yml logs -f

# Scale backend for high load
docker-compose -f docker-compose.prod.yml up -d --scale backend=3
```

### **Nginx Configuration**
```nginx
# nginx.conf
upstream backend {
    server backend:8001;
}

server {
    listen 80;
    server_name your-domain.com;

    # Frontend
    location / {
        proxy_pass http://frontend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # Backend API
    location /api/ {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_read_timeout 300s;
        proxy_connect_timeout 75s;
    }

    # ISO Downloads
    location /downloads/ {
        alias /var/www/downloads/;
        add_header Content-Disposition attachment;
    }
}
```

## 🧪 Testing

### **Frontend Testing**
The application includes comprehensive frontend testing covering:

✅ **UI Components**
- Profile selection with visual feedback
- Package search and filtering functionality
- Desktop environment selection
- User configuration forms
- Build progress tracking

✅ **User Workflows**
- Complete ISO creation workflow
- Real-time build monitoring
- Download functionality
- Error handling and notifications

✅ **Responsive Design**
- Desktop, tablet, and mobile layouts
- Touch-friendly interface
- Proper scaling and typography

### **Backend Testing**
Comprehensive API testing includes:

✅ **API Endpoints**
- Profile management API
- Package categories API
- Desktop environments API
- ISO configuration CRUD operations
- Build status tracking
- File download endpoints

✅ **Database Integration**
- MongoDB connection handling
- Data persistence and retrieval
- Build log management
- Error handling

✅ **Build System**
- ISO creation workflow
- Progress tracking
- Status management
- File output handling

### **Running Tests**
```bash
# Frontend tests
cd frontend
yarn test

# Backend tests  
cd backend
python -m pytest tests/

# Integration tests
python backend_test.py

# Load testing
cd tests
python load_test.py
```

## 🔒 Security Considerations

### **Input Validation**
- All user inputs are validated using Pydantic models
- Package names are sanitized to prevent injection
- File paths are validated for security

### **File Management**
- ISO files are stored in sandboxed directories
- Download URLs are validated and sanitized
- Automatic cleanup of old builds

### **API Security**
- CORS configuration for production
- Rate limiting for build endpoints
- Input size limits for configurations

### **Production Hardening**
```python
# Recommended production settings
CORS_ORIGINS = ["https://your-domain.com"]
MAX_ISO_SIZE = "4GB"  
BUILD_TIMEOUT = "30min"
RATE_LIMIT = "5 builds per hour"
```

## 🤝 Contributing

We welcome contributions! Please follow these guidelines:

### **Development Workflow**
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes with proper tests
4. Commit with clear messages: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

### **Code Standards**
- **Frontend**: ESLint + Prettier for React/JavaScript
- **Backend**: Black + isort for Python formatting
- **Commits**: Conventional commit messages
- **Tests**: Required for new features

### **Areas for Contribution**
- 🎨 UI/UX improvements
- 📦 Additional package categories
- 🖥️ New desktop environment support
- 🚀 Performance optimizations
- 📱 Mobile experience enhancements
- 🧪 Additional testing coverage

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Arch Linux Community** - For the amazing distribution
- **archiso** - The underlying ISO building tool
- **React Community** - For the fantastic frontend framework
- **FastAPI** - For the high-performance backend framework
- **Radix UI** - For the accessible UI components

## 📞 Support

- 📖 **Documentation**: Check this README and inline code comments
- 🐛 **Bug Reports**: Open an issue with detailed information
- 💡 **Feature Requests**: Submit an issue with your proposal
- 💬 **Questions**: Start a discussion in the repository

---

**Built with ❤️ for the Arch Linux community**

*"I use Arch, BTW" - Now make it easier for everyone else!*