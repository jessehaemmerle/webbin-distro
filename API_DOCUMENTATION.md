# 📡 API Documentation - Arch ISO Builder

This document provides comprehensive API documentation for the Arch ISO Builder backend service.

## 🔗 Base URL

**Development**: `http://localhost:8001/api`  
**Production**: `https://your-domain.com/api`

## 📋 API Overview

The Arch ISO Builder API provides endpoints for:
- Managing installation profiles
- Browsing package categories
- Configuring desktop environments
- Creating and managing ISO builds
- Tracking build progress
- Downloading completed ISOs

## 🔐 Authentication

Currently, the API operates without authentication for simplicity. In production environments, consider implementing:
- JWT token authentication
- API key authentication
- Rate limiting per user/IP

## 📊 Response Format

All API responses follow a consistent JSON format:

### **Success Response**
```json
{
  "data": { ... },
  "status": "success",
  "message": "Operation completed successfully"
}
```

### **Error Response**
```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": { ... }
  },
  "status": "error"
}
```

## 📚 Endpoints

### **1. Health Check**

#### **GET /** 
Check API health and version information.

**Response:**
```json
{
  "message": "Arch ISO Builder API v1.0"
}
```

**Example:**
```bash
curl -X GET "http://localhost:8001/api/"
```

---

### **2. Installation Profiles**

#### **GET /profiles**
Retrieve all available installation profiles.

**Response:**
```json
[
  {
    "id": "custom",
    "name": "Custom Configuration",
    "description": "Start from scratch and choose exactly what you need",
    "icon": "🛠️",
    "packages": ["base", "linux", "linux-firmware", "grub"]
  },
  {
    "id": "minimal",
    "name": "Minimal Installation", 
    "description": "Bare minimum packages for a functional Arch system",
    "icon": "📦",
    "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "networkmanager", "sudo"]
  },
  {
    "id": "desktop",
    "name": "Desktop Workstation",
    "description": "Complete desktop environment with common applications", 
    "icon": "🖥️",
    "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "gnome", "firefox", "libreoffice-fresh", "git", "vim"]
  },
  {
    "id": "developer",
    "name": "Developer Setup",
    "description": "Development tools and programming environments",
    "icon": "👨‍💻",
    "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "i3-wm", "git", "vim", "code", "docker", "nodejs", "python", "go"]
  },
  {
    "id": "gaming",
    "name": "Gaming Rig",
    "description": "Optimized for gaming with graphics drivers and gaming tools",
    "icon": "🎮", 
    "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "kde-plasma", "steam", "lutris", "discord", "nvidia"]
  },
  {
    "id": "server",
    "name": "Server Installation",
    "description": "Headless server setup with essential services",
    "icon": "🖧",
    "packages": ["base", "base-devel", "linux", "linux-firmware", "grub", "efibootmgr", "openssh", "nginx", "docker", "git"]
  }
]
```

**Profile Fields:**
- `id`: Unique profile identifier
- `name`: Human-readable profile name
- `description`: Profile description
- `icon`: Emoji icon for UI display
- `packages`: List of pre-selected package names

**Example:**
```bash
curl -X GET "http://localhost:8001/api/profiles"
```

---

### **3. Package Categories**

#### **GET /packages**
Retrieve all package categories with individual packages.

**Response:**
```json
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
      },
      {
        "name": "base-devel",
        "description": "Basic tools to build Arch Linux packages", 
        "selected": false,
        "required": false
      },
      {
        "name": "linux",
        "description": "The Linux kernel and modules",
        "selected": true,
        "required": true
      }
    ]
  },
  {
    "id": "development",
    "name": "Development Tools",
    "description": "Programming and development packages",
    "packages": [
      {
        "name": "git",
        "description": "Fast distributed version control system",
        "selected": false,
        "required": false
      },
      {
        "name": "vim",
        "description": "Vi Improved text editor",
        "selected": false,
        "required": false
      }
    ]
  }
]
```

**Category Fields:**
- `id`: Unique category identifier
- `name`: Category display name
- `description`: Category description
- `packages`: Array of package objects

**Package Fields:**
- `name`: Package name in Arch repositories
- `description`: Package description
- `selected`: Default selection state
- `required`: Whether package cannot be deselected

**Example:**
```bash
curl -X GET "http://localhost:8001/api/packages"
```

---

### **4. Desktop Environments**

#### **GET /desktop-environments**
Retrieve available desktop environment options.

**Response:**
```json
[
  {
    "id": "none",
    "name": "No Desktop Environment",
    "description": "Command line only",
    "selected": true
  },
  {
    "id": "gnome", 
    "name": "GNOME",
    "description": "Modern, easy-to-use desktop environment",
    "selected": false
  },
  {
    "id": "kde",
    "name": "KDE Plasma",
    "description": "Feature-rich and customizable desktop",
    "selected": false
  },
  {
    "id": "xfce",
    "name": "XFCE", 
    "description": "Lightweight, fast desktop environment",
    "selected": false
  },
  {
    "id": "i3",
    "name": "i3 Window Manager",
    "description": "Tiling window manager for advanced users",
    "selected": false
  }
]
```

**Desktop Environment Fields:**
- `id`: Unique desktop environment identifier
- `name`: Display name
- `description`: Description of the desktop environment
- `selected`: Default selection state

**Example:**
```bash
curl -X GET "http://localhost:8001/api/desktop-environments"
```

---

### **5. ISO Configuration Management**

#### **POST /iso-configs**
Create a new ISO configuration and start the build process.

**Request Body:**
```json
{
  "name": "My Custom Arch ISO",
  "profile_id": "desktop",
  "selected_packages": [
    "base",
    "base-devel", 
    "linux",
    "linux-firmware",
    "grub",
    "efibootmgr",
    "gnome",
    "firefox",
    "git",
    "vim"
  ],
  "desktop_environment": "gnome",
  "user_config": {
    "hostname": "archbox",
    "username": "user",
    "timezone": "America/New_York",
    "locale": "en_US.UTF-8",
    "keymap": "us"
  },
  "custom_settings": {
    "enable_multilib": true,
    "install_yay": true
  }
}
```

**Request Fields:**
- `name`: Human-readable name for this ISO configuration
- `profile_id`: ID of the selected profile (from /profiles)
- `selected_packages`: Array of package names to include
- `desktop_environment`: Desktop environment ID (from /desktop-environments)
- `user_config`: User and system configuration
- `custom_settings`: Additional custom settings (optional)

**User Config Fields:**
- `hostname`: System hostname
- `username`: Primary user account name
- `timezone`: System timezone (e.g., "America/New_York")
- `locale`: System locale (e.g., "en_US.UTF-8")
- `keymap`: Keyboard layout (e.g., "us")

**Response:**
```json
{
  "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "name": "My Custom Arch ISO",
  "profile_id": "desktop",
  "status": "pending",
  "progress": 0,
  "size": null,
  "download_url": null,
  "error_message": null,
  "created_at": "2025-01-08T15:30:00.123Z",
  "updated_at": "2025-01-08T15:30:00.123Z"
}
```

**Status Values:**
- `pending`: Configuration created, build not started
- `building`: ISO build in progress
- `completed`: Build finished successfully
- `failed`: Build failed with errors

**Example:**
```bash
curl -X POST "http://localhost:8001/api/iso-configs" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test ISO",
    "profile_id": "minimal",
    "selected_packages": ["base", "linux", "grub"],
    "desktop_environment": "none",
    "user_config": {
      "hostname": "testbox",
      "username": "tester",
      "timezone": "UTC",
      "locale": "en_US.UTF-8",
      "keymap": "us"
    }
  }'
```

---

#### **GET /iso-configs**
Retrieve all ISO configurations.

**Query Parameters:**
- `limit` (optional): Maximum number of results (default: 50)
- `offset` (optional): Number of results to skip (default: 0)
- `status` (optional): Filter by status (pending, building, completed, failed)

**Response:**
```json
[
  {
    "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "name": "My Custom Arch ISO", 
    "profile_id": "desktop",
    "status": "completed",
    "progress": 100,
    "size": "2.1 GB",
    "download_url": "/downloads/My_Custom_Arch_ISO_f47ac10b.iso",
    "error_message": null,
    "created_at": "2025-01-08T15:30:00.123Z",
    "updated_at": "2025-01-08T15:45:30.456Z"
  },
  {
    "id": "b23ef89c-12dd-4573-b678-1f13c3d4e580",
    "name": "Development Environment",
    "profile_id": "developer",
    "status": "building", 
    "progress": 75,
    "size": null,
    "download_url": null,
    "error_message": null,
    "created_at": "2025-01-08T16:00:00.789Z",
    "updated_at": "2025-01-08T16:10:15.234Z"
  }
]
```

**Example:**
```bash
# Get all configurations
curl -X GET "http://localhost:8001/api/iso-configs"

# Get only completed builds
curl -X GET "http://localhost:8001/api/iso-configs?status=completed"

# Get with pagination
curl -X GET "http://localhost:8001/api/iso-configs?limit=10&offset=20"
```

---

#### **GET /iso-configs/{id}**
Retrieve a specific ISO configuration by ID.

**Path Parameters:**
- `id`: ISO configuration UUID

**Response:**
```json
{
  "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "name": "My Custom Arch ISO",
  "profile_id": "desktop", 
  "status": "completed",
  "progress": 100,
  "size": "2.1 GB",
  "download_url": "/downloads/My_Custom_Arch_ISO_f47ac10b.iso",
  "error_message": null,
  "created_at": "2025-01-08T15:30:00.123Z",
  "updated_at": "2025-01-08T15:45:30.456Z"
}
```

**Example:**
```bash
curl -X GET "http://localhost:8001/api/iso-configs/f47ac10b-58cc-4372-a567-0e02b2c3d479"
```

---

#### **DELETE /iso-configs/{id}**
Delete an ISO configuration and associated files.

**Path Parameters:**
- `id`: ISO configuration UUID

**Response:**
```json
{
  "message": "ISO configuration deleted successfully"
}
```

**Example:**
```bash
curl -X DELETE "http://localhost:8001/api/iso-configs/f47ac10b-58cc-4372-a567-0e02b2c3d479"
```

---

### **6. Build Logs**

#### **GET /iso-configs/{id}/logs**
Retrieve build logs for a specific ISO configuration.

**Path Parameters:**
- `id`: ISO configuration UUID

**Query Parameters:**
- `limit` (optional): Maximum number of log entries (default: 100)
- `level` (optional): Filter by log level (INFO, WARNING, ERROR)

**Response:**
```json
[
  {
    "id": "log_entry_uuid",
    "iso_config_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "timestamp": "2025-01-08T15:30:05.123Z",
    "level": "INFO",
    "message": "Starting ISO build process",
    "details": {
      "build_phase": "initialization"
    }
  },
  {
    "id": "log_entry_uuid_2",
    "iso_config_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479", 
    "timestamp": "2025-01-08T15:32:15.456Z",
    "level": "INFO",
    "message": "Preparing archiso environment",
    "details": {
      "build_phase": "environment_setup",
      "progress": 10
    }
  },
  {
    "id": "log_entry_uuid_3",
    "iso_config_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
    "timestamp": "2025-01-08T15:45:30.789Z",
    "level": "INFO", 
    "message": "ISO build completed successfully",
    "details": {
      "build_phase": "completion",
      "progress": 100,
      "output_file": "/downloads/My_Custom_Arch_ISO_f47ac10b.iso",
      "file_size": "2.1 GB"
    }
  }
]
```

**Log Entry Fields:**
- `id`: Unique log entry identifier
- `iso_config_id`: Associated ISO configuration ID
- `timestamp`: When the log entry was created
- `level`: Log level (INFO, WARNING, ERROR)
- `message`: Human-readable log message
- `details`: Additional structured data

**Example:**
```bash
# Get all logs for a configuration
curl -X GET "http://localhost:8001/api/iso-configs/f47ac10b-58cc-4372-a567-0e02b2c3d479/logs"

# Get only error logs
curl -X GET "http://localhost:8001/api/iso-configs/f47ac10b-58cc-4372-a567-0e02b2c3d479/logs?level=ERROR"

# Get recent logs
curl -X GET "http://localhost:8001/api/iso-configs/f47ac10b-58cc-4372-a567-0e02b2c3d479/logs?limit=10"
```

---

### **7. File Downloads**

#### **GET /downloads/{filename}**
Download a completed ISO file.

**Path Parameters:**
- `filename`: ISO filename (from download_url)

**Response:**
- Binary ISO file with appropriate headers
- Content-Type: application/octet-stream
- Content-Disposition: attachment

**Example:**
```bash
# Download ISO file
curl -X GET "http://localhost:8001/api/downloads/My_Custom_Arch_ISO_f47ac10b.iso" \
  -o my_custom_arch.iso

# Get file info without downloading
curl -I "http://localhost:8001/api/downloads/My_Custom_Arch_ISO_f47ac10b.iso"
```

---

## 🔄 Build Process Flow

Understanding the ISO build process helps with API integration:

1. **Configuration Creation** (`POST /iso-configs`)
   - Validates input parameters
   - Creates database entry with `pending` status
   - Returns configuration ID immediately
   - Starts background build process

2. **Build Phases** (monitor via `GET /iso-configs/{id}`)
   - **Pending** (0%): Build queued
   - **Environment Setup** (10%): Preparing build environment
   - **Package Configuration** (25%): Setting up package lists
   - **User Configuration** (40%): Configuring system settings
   - **Desktop Setup** (55%): Installing desktop environment
   - **ISO Building** (70-90%): Creating ISO image
   - **Finalization** (100%): Completing and moving files

3. **Completion**
   - Status changes to `completed`
   - `download_url` becomes available
   - File size is calculated and stored

## 📊 Real-time Updates

For real-time build monitoring, implement polling:

```javascript
// Example: Poll for build status updates
async function monitorBuild(configId) {
  const pollInterval = 3000; // 3 seconds
  
  const poll = async () => {
    try {
      const response = await fetch(`/api/iso-configs/${configId}`);
      const config = await response.json();
      
      console.log(`Build progress: ${config.progress}%`);
      
      if (config.status === 'completed') {
        console.log('Build completed!', config.download_url);
        return;
      } else if (config.status === 'failed') {
        console.error('Build failed:', config.error_message);
        return;
      }
      
      // Continue polling
      setTimeout(poll, pollInterval);
    } catch (error) {
      console.error('Error polling build status:', error);
    }
  };
  
  poll();
}
```

## ⚠️ Error Handling

### **Common Error Codes**

#### **400 Bad Request**
```json
{
  "detail": "Invalid package name: 'invalid-package'"
}
```

#### **404 Not Found**
```json
{
  "detail": "ISO configuration not found"
}
```

#### **422 Validation Error**
```json
{
  "detail": [
    {
      "loc": ["body", "profile_id"],
      "msg": "field required",
      "type": "value_error.missing"
    }
  ]
}
```

#### **500 Internal Server Error**
```json
{
  "detail": "Build process failed: insufficient disk space"
}
```

### **Handling Build Failures**

When builds fail, check:
1. Build logs via `/iso-configs/{id}/logs`
2. Error message in configuration object
3. System resource availability
4. Package availability in repositories

## 🔒 Rate Limiting

Production deployments should implement rate limiting:

- **General API**: 100 requests per minute per IP
- **Build Creation**: 5 builds per hour per IP
- **Download Endpoints**: 10 downloads per minute per IP

Example rate limit headers:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1641677400
```

## 📈 Performance Considerations

### **Optimization Tips**

1. **Pagination**: Use limit/offset for large result sets
2. **Caching**: Cache profile and package data (rarely changes)
3. **Compression**: Enable gzip compression for API responses
4. **Background Processing**: Builds run asynchronously
5. **File Streaming**: Large downloads use streaming responses

### **Resource Requirements**

- **CPU**: Builds are CPU-intensive (1-4 cores recommended)
- **Memory**: 2-4GB RAM per concurrent build
- **Storage**: 5-10GB per ISO (temporary + final)
- **Network**: Bandwidth for package downloads

## 🧪 Testing the API

### **Using curl**
```bash
# Test complete workflow
PROFILE_ID="minimal"
CONFIG_ID=$(curl -s -X POST "http://localhost:8001/api/iso-configs" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"Test Build\",
    \"profile_id\": \"$PROFILE_ID\",
    \"selected_packages\": [\"base\", \"linux\", \"grub\"],
    \"desktop_environment\": \"none\",
    \"user_config\": {
      \"hostname\": \"testbox\",
      \"username\": \"tester\",
      \"timezone\": \"UTC\",
      \"locale\": \"en_US.UTF-8\",
      \"keymap\": \"us\"
    }
  }" | jq -r '.id')

echo "Created configuration: $CONFIG_ID"

# Monitor progress
while true; do
  STATUS=$(curl -s "http://localhost:8001/api/iso-configs/$CONFIG_ID" | jq -r '.status')
  PROGRESS=$(curl -s "http://localhost:8001/api/iso-configs/$CONFIG_ID" | jq -r '.progress')
  
  echo "Status: $STATUS, Progress: $PROGRESS%"
  
  if [ "$STATUS" = "completed" ] || [ "$STATUS" = "failed" ]; then
    break
  fi
  
  sleep 5
done
```

### **Using Python**
```python
import requests
import time
import json

BASE_URL = "http://localhost:8001/api"

# Create ISO configuration
config_data = {
    "name": "Python Test Build",
    "profile_id": "desktop",
    "selected_packages": ["base", "linux", "gnome", "firefox"],
    "desktop_environment": "gnome",
    "user_config": {
        "hostname": "pythontest",
        "username": "pythonuser", 
        "timezone": "America/New_York",
        "locale": "en_US.UTF-8",
        "keymap": "us"
    }
}

response = requests.post(f"{BASE_URL}/iso-configs", json=config_data)
config = response.json()
config_id = config["id"]

print(f"Created configuration: {config_id}")

# Monitor build progress
while True:
    response = requests.get(f"{BASE_URL}/iso-configs/{config_id}")
    config = response.json()
    
    print(f"Status: {config['status']}, Progress: {config['progress']}%")
    
    if config['status'] in ['completed', 'failed']:
        break
        
    time.sleep(5)

if config['status'] == 'completed':
    print(f"Download URL: {config['download_url']}")
else:
    print(f"Build failed: {config['error_message']}")
```

---

## 📞 Support

For API support:
- 📖 **Documentation Issues**: Check this document and inline code comments
- 🐛 **Bug Reports**: Include API endpoint, request/response, and error details
- 💡 **Feature Requests**: Describe the use case and expected behavior

**Base URL**: Remember to update the base URL for your deployment environment!

---

**API Version**: 1.0  
**Last Updated**: January 2025