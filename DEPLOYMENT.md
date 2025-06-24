# 🚀 Deployment Guide - Arch ISO Builder

This guide provides detailed instructions for deploying the Arch ISO Builder application to your own server.

## 📋 Prerequisites

### **System Requirements**
- **OS**: Ubuntu 20.04+, CentOS 8+, or similar Linux distribution
- **RAM**: 4GB minimum (8GB recommended for concurrent builds)
- **Storage**: 50GB minimum (100GB+ recommended for multiple ISOs)
- **CPU**: 2+ cores (4+ cores recommended)
- **Network**: Stable internet connection for package downloads

### **Software Requirements**
- Docker 20.10+
- Docker Compose 2.0+
- Git
- Domain name (for production)
- SSL certificate (Let's Encrypt recommended)

## 🔧 Server Setup

### **1. Initial Server Configuration**

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Install Git
sudo apt install git -y
```

### **2. Firewall Configuration**

```bash
# Enable UFW
sudo ufw enable

# Allow SSH
sudo ufw allow 22

# Allow HTTP/HTTPS
sudo ufw allow 80
sudo ufw allow 443

# Check status
sudo ufw status
```

## 📦 Application Deployment

### **1. Clone Repository**

```bash
# Clone to your preferred directory
cd /opt
sudo git clone <your-repository-url> arch-iso-builder
sudo chown -R $USER:$USER arch-iso-builder
cd arch-iso-builder
```

### **2. Environment Configuration**

```bash
# Create production environment files
cat > frontend/.env << EOF
REACT_APP_BACKEND_URL=https://your-domain.com
EOF

cat > backend/.env << EOF
MONGO_URL=mongodb://mongo:27017/
DB_NAME=arch_iso_builder
JWT_SECRET=$(openssl rand -hex 32)
ALLOWED_ORIGINS=https://your-domain.com
EOF
```

### **3. Docker Compose Production Setup**

Create `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    container_name: arch_iso_frontend
    restart: unless-stopped
    environment:
      - NODE_ENV=production
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.prod
    container_name: arch_iso_backend
    restart: unless-stopped
    environment:
      - MONGO_URL=mongodb://mongo:27017/
      - DB_NAME=arch_iso_builder
    env_file:
      - backend/.env
    volumes:
      - iso_storage:/app/downloads
      - build_logs:/app/logs
    depends_on:
      - mongo

  mongo:
    image: mongo:6.0
    container_name: arch_iso_mongo
    restart: unless-stopped
    volumes:
      - mongo_data:/data/db
      - ./mongo-init:/docker-entrypoint-initdb.d
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_ROOT_PASSWORD}
      MONGO_INITDB_DATABASE: arch_iso_builder

  nginx:
    image: nginx:alpine
    container_name: arch_iso_nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
      - iso_storage:/var/www/downloads
    depends_on:
      - frontend
      - backend

volumes:
  mongo_data:
    driver: local
  iso_storage:
    driver: local
  build_logs:
    driver: local

networks:
  default:
    name: arch_iso_network
```

### **4. Nginx Configuration**

Create `nginx/nginx.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:3000;
    }

    upstream backend {
        server backend:8001;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/m;
    limit_req_zone $binary_remote_addr zone=build:10m rate=5r/h;

    server {
        listen 80;
        server_name your-domain.com www.your-domain.com;
        
        # Redirect HTTP to HTTPS
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name your-domain.com www.your-domain.com;

        # SSL Configuration
        ssl_certificate /etc/nginx/ssl/fullchain.pem;
        ssl_certificate_key /etc/nginx/ssl/privkey.pem;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
        ssl_prefer_server_ciphers off;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

        # Client max body size (for uploads)
        client_max_body_size 100M;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Backend API
        location /api/ {
            limit_req zone=api burst=20 nodelay;
            
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Timeouts for long-running builds
            proxy_read_timeout 1800s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 1800s;
        }

        # Build endpoints with stricter rate limiting
        location /api/iso-configs {
            limit_req zone=build burst=2 nodelay;
            
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            proxy_read_timeout 1800s;
            proxy_connect_timeout 75s;
            proxy_send_timeout 1800s;
        }

        # ISO Downloads
        location /downloads/ {
            alias /var/www/downloads/;
            add_header Content-Disposition attachment;
            add_header X-Content-Type-Options nosniff;
            
            # Cache control for ISO files
            expires 7d;
            add_header Cache-Control "public, immutable";
        }

        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
}
```

### **5. SSL Certificate Setup (Let's Encrypt)**

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Create SSL directory
mkdir -p nginx/ssl

# Stop nginx temporarily
docker-compose -f docker-compose.prod.yml stop nginx

# Get certificate
sudo certbot certonly --standalone -d your-domain.com -d www.your-domain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/your-domain.com/fullchain.pem nginx/ssl/
sudo cp /etc/letsencrypt/live/your-domain.com/privkey.pem nginx/ssl/
sudo chown $USER:$USER nginx/ssl/*

# Set up auto-renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

### **6. Production Dockerfiles**

Create `frontend/Dockerfile.prod`:

```dockerfile
# Multi-stage build for production
FROM node:18-alpine as builder

WORKDIR /app
COPY package*.json ./
COPY yarn.lock ./
RUN yarn install --frozen-lockfile

COPY . .
RUN yarn build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]
```

Create `backend/Dockerfile.prod`:

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Create directories
RUN mkdir -p downloads logs

# Run as non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8001

CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "2"]
```

## 🚀 Launch Application

### **1. Build and Start Services**

```bash
# Generate MongoDB root password
export MONGO_ROOT_PASSWORD=$(openssl rand -base64 32)
echo "MongoDB Root Password: $MONGO_ROOT_PASSWORD" > .mongo_password

# Build and start all services
docker-compose -f docker-compose.prod.yml up -d --build

# Check service status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f
```

### **2. Verify Deployment**

```bash
# Test frontend
curl -I https://your-domain.com

# Test backend API
curl https://your-domain.com/api/

# Test health endpoint
curl https://your-domain.com/health

# Check SSL
openssl s_client -connect your-domain.com:443 -servername your-domain.com
```

## 📊 Monitoring & Maintenance

### **1. Log Management**

```bash
# View application logs
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f frontend

# Set up log rotation
cat > /etc/logrotate.d/docker-compose << EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
EOF
```

### **2. Backup Strategy**

```bash
# Create backup script
cat > /opt/arch-iso-builder/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/backup/arch-iso-builder"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup MongoDB
docker exec arch_iso_mongo mongodump --out /tmp/backup
docker cp arch_iso_mongo:/tmp/backup $BACKUP_DIR/mongo_$DATE

# Backup ISO files
tar -czf $BACKUP_DIR/isos_$DATE.tar.gz /var/lib/docker/volumes/arch-iso-builder_iso_storage

# Backup configuration
tar -czf $BACKUP_DIR/config_$DATE.tar.gz /opt/arch-iso-builder

# Clean old backups (keep 7 days)
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "mongo_*" -mtime +7 -exec rm -rf {} \;

echo "Backup completed: $DATE"
EOF

chmod +x /opt/arch-iso-builder/backup.sh

# Schedule daily backups
echo "0 2 * * * /opt/arch-iso-builder/backup.sh >> /var/log/backup.log 2>&1" | sudo crontab -
```

### **3. Health Monitoring**

```bash
# Create health check script
cat > /opt/arch-iso-builder/health-check.sh << 'EOF'
#!/bin/bash

# Check if services are running
SERVICES=("arch_iso_frontend" "arch_iso_backend" "arch_iso_mongo" "arch_iso_nginx")

for service in "${SERVICES[@]}"; do
    if ! docker ps --format "table {{.Names}}" | grep -q $service; then
        echo "ERROR: $service is not running"
        docker-compose -f /opt/arch-iso-builder/docker-compose.prod.yml restart $service
    fi
done

# Check disk space
DISK_USAGE=$(df /var/lib/docker | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 85 ]; then
    echo "WARNING: Disk usage is at $DISK_USAGE%"
    # Clean old Docker images
    docker image prune -a -f
fi

# Check frontend endpoint
if ! curl -f -s https://your-domain.com/health > /dev/null; then
    echo "ERROR: Frontend health check failed"
fi

# Check backend endpoint
if ! curl -f -s https://your-domain.com/api/ > /dev/null; then
    echo "ERROR: Backend health check failed"
fi
EOF

chmod +x /opt/arch-iso-builder/health-check.sh

# Run health check every 5 minutes
echo "*/5 * * * * /opt/arch-iso-builder/health-check.sh >> /var/log/health-check.log 2>&1" | crontab -
```

### **4. Performance Optimization**

```bash
# Add swap if needed (for build processes)
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Optimize Docker
cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker
```

## 🔧 Troubleshooting

### **Common Issues**

#### **Service Won't Start**
```bash
# Check service logs
docker-compose -f docker-compose.prod.yml logs service_name

# Check resource usage
docker stats

# Restart specific service
docker-compose -f docker-compose.prod.yml restart service_name
```

#### **Build Failures**
```bash
# Check available disk space
df -h

# Check Docker disk usage
docker system df

# Clean up Docker
docker system prune -a

# Check build logs
docker-compose -f docker-compose.prod.yml logs backend | grep -i build
```

#### **Database Connection Issues**
```bash
# Check MongoDB status
docker exec arch_iso_mongo mongo --eval "db.adminCommand('ismaster')"

# Reset MongoDB
docker-compose -f docker-compose.prod.yml restart mongo

# Check connection from backend
docker exec arch_iso_backend python -c "from database import client; print(client.server_info())"
```

### **Security Hardening**

```bash
# Update system regularly
sudo apt update && sudo apt upgrade -y

# Configure fail2ban for SSH protection
sudo apt install fail2ban -y
sudo systemctl enable fail2ban

# Set up firewall rules
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80,443/tcp
sudo ufw enable

# Disable root SSH login
sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl restart sshd
```

## 📞 Support

If you encounter issues during deployment:

1. **Check Logs**: Always start with service logs
2. **Verify Prerequisites**: Ensure all requirements are met
3. **Test Components**: Test each service individually
4. **Check Resources**: Monitor CPU, memory, and disk usage
5. **Review Configuration**: Verify environment variables and config files

For additional support, please open an issue in the repository with:
- Deployment environment details
- Error logs
- Steps to reproduce the issue

---

**Happy Deploying! 🚀**