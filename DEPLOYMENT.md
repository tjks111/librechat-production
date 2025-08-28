# LibreChat Production Deployment Guide

This guide provides step-by-step instructions for deploying your customized LibreChat instance to Digital Ocean.

## Prerequisites

- Digital Ocean Droplet (Ubuntu 20.04+ recommended)
- Docker and Docker Compose installed on the droplet
- Git installed on the droplet
- Your GitHub repository with LibreChat code
- Domain name (optional but recommended)

## Quick Deployment

### Option 1: Automated Script (Recommended)

1. **SSH into your Digital Ocean droplet:**
   ```bash
   ssh root@your-droplet-ip
   ```

2. **Download and run the deployment script:**
   ```bash
   wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/deploy-to-production.sh
   chmod +x deploy-to-production.sh
   ./deploy-to-production.sh
   ```

### Option 2: Manual Deployment

1. **SSH into your Digital Ocean droplet:**
   ```bash
   ssh root@your-droplet-ip
   ```

2. **Stop existing LibreChat (if any):**
   ```bash
   docker-compose down
   docker system prune -a -f
   ```

3. **Clone your repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git /opt/librechat
   cd /opt/librechat
   ```

4. **Configure environment:**
   ```bash
   cp .env.example .env
   nano .env  # Edit with your settings
   ```

5. **Update domain settings in .env:**
   ```bash
   # Replace YOUR_DOMAIN_OR_IP with your actual domain or IP
   DOMAIN_CLIENT=http://your-domain.com
   DOMAIN_SERVER=http://your-domain.com
   ```

6. **Create necessary directories:**
   ```bash
   mkdir -p uploads logs images shared
   chmod -R 755 .
   ```

7. **Deploy with production configuration:**
   ```bash
   docker-compose -f deploy-compose.yml up -d
   ```

## Configuration

### Environment Variables

Key environment variables to configure in `.env`:

```bash
# Server Configuration
HOST=0.0.0.0
PORT=3080

# Database
MONGO_URI=mongodb://mongodb:27017/LibreChat

# Domains (IMPORTANT: Update these!)
DOMAIN_CLIENT=http://your-domain.com
DOMAIN_SERVER=http://your-domain.com

# Security
JWT_SECRET=your-super-secret-jwt-key
JWT_REFRESH_SECRET=your-super-secret-refresh-key

# API Keys (Add your API keys here)
OPENAI_API_KEY=your-openai-api-key
ANTHROPIC_API_KEY=your-anthropic-api-key
# ... other API keys
```

### SSL/HTTPS Setup (Recommended)

For production, set up SSL using Let's Encrypt:

1. **Install Certbot:**
   ```bash
   sudo apt update
   sudo apt install certbot python3-certbot-nginx
   ```

2. **Get SSL certificate:**
   ```bash
   sudo certbot --nginx -d your-domain.com
   ```

3. **Update your .env file:**
   ```bash
   DOMAIN_CLIENT=https://your-domain.com
   DOMAIN_SERVER=https://your-domain.com
   ```

## Monitoring and Maintenance

### Check Status
```bash
cd /opt/librechat
docker-compose -f deploy-compose.yml ps
```

### View Logs
```bash
# All services
docker-compose -f deploy-compose.yml logs -f

# Specific service
docker-compose -f deploy-compose.yml logs -f api
```

### Update Deployment
```bash
cd /opt/librechat
git pull origin main
docker-compose -f deploy-compose.yml down
docker-compose -f deploy-compose.yml pull
docker-compose -f deploy-compose.yml up -d
```

### Backup
```bash
# Backup database
docker exec chat-mongodb mongodump --out /data/backup

# Backup uploads and logs
tar -czf librechat-backup-$(date +%Y%m%d).tar.gz uploads/ logs/ .env
```

## Troubleshooting

### Common Issues

1. **Containers not starting:**
   ```bash
   docker-compose -f deploy-compose.yml logs
   ```

2. **Permission issues:**
   ```bash
   sudo chown -R $USER:$USER /opt/librechat
   chmod -R 755 /opt/librechat
   ```

3. **Port conflicts:**
   ```bash
   sudo netstat -tulpn | grep :3080
   sudo netstat -tulpn | grep :80
   ```

4. **Database connection issues:**
   ```bash
   docker-compose -f deploy-compose.yml exec mongodb mongo --eval "db.stats()"
   ```

### Reset Everything
```bash
cd /opt/librechat
docker-compose -f deploy-compose.yml down -v
docker system prune -a -f
docker-compose -f deploy-compose.yml up -d
```

## Security Considerations

1. **Change default passwords and secrets**
2. **Use strong JWT secrets**
3. **Enable firewall:**
   ```bash
   sudo ufw enable
   sudo ufw allow ssh
   sudo ufw allow 80
   sudo ufw allow 443
   ```
4. **Regular updates:**
   ```bash
   sudo apt update && sudo apt upgrade
   ```

## MCP Servers

This deployment includes several MCP (Model Context Protocol) servers:

- **Docker MCP**: Container management
- **EDGAR SEC**: Financial data access
- **Cloudflare**: Cloudflare API integration
- **Filesystem**: File operations

MCP servers are automatically configured and started with the main application.

## Support

If you encounter issues:

1. Check the logs: `docker-compose -f deploy-compose.yml logs -f`
2. Verify your .env configuration
3. Ensure all required API keys are set
4. Check firewall and network settings

## File Structure

```
/opt/librechat/
├── api/                 # Backend API
├── client/              # Frontend React app
├── uploads/             # User uploads
├── logs/                # Application logs
├── images/              # Static images
├── shared/              # Shared files
├── .env                 # Environment configuration
├── deploy-compose.yml   # Production Docker Compose
└── librechat.yaml       # LibreChat configuration
```

This deployment is optimized for production use with proper security, monitoring, and maintenance capabilities.