# 🚀 Complete Deployment Guide - Next Steps

## Step 1: Create Your GitHub Repository

1. **Go to GitHub.com and create a new repository:**
   - Repository name: `librechat-production` (or your preferred name)
   - Description: `Custom LibreChat deployment with MCP servers`
   - Set to **Public** or **Private** (your choice)
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)

2. **Copy the repository URL** (it will look like: `https://github.com/YOUR_USERNAME/librechat-production.git`)

## Step 2: Connect Your Local Repository to GitHub

Run these commands in your terminal (replace `YOUR_USERNAME` and `YOUR_REPO_NAME`):

```bash
# Add your new GitHub repository as origin
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Push your code to GitHub
git push -u origin main
```

## Step 3: Update Deployment Scripts

After pushing to GitHub, update the repository URL in your deployment scripts:

1. **Edit `deploy-to-production.sh`:**
   - Change `REPO_URL="https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git"`

2. **Edit `deploy-to-production.bat`:**
   - Change `set REPO_URL=https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git`

3. **Edit `DEPLOYMENT.md`:**
   - Update all GitHub URLs to point to your repository

## Step 4: Deploy to Digital Ocean

### Option A: Automated Deployment (Recommended)

1. **SSH into your Digital Ocean droplet:**
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

2. **Download and run the deployment script:**
   ```bash
   wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO_NAME/main/deploy-to-production.sh
   chmod +x deploy-to-production.sh
   ./deploy-to-production.sh
   ```

### Option B: Manual Deployment

1. **SSH into your Digital Ocean droplet:**
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

2. **Stop existing LibreChat:**
   ```bash
   # Find and stop existing containers
   docker ps
   docker-compose down || true
   docker stop $(docker ps -aq) || true
   docker rm $(docker ps -aq) || true
   ```

3. **Clean up old installation:**
   ```bash
   # Backup existing data if needed
   cp -r /opt/librechat /opt/librechat-backup-$(date +%Y%m%d) || true
   
   # Remove old installation
   rm -rf /opt/librechat
   ```

4. **Clone your repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git /opt/librechat
   cd /opt/librechat
   ```

5. **Configure environment:**
   ```bash
   # Copy and edit environment file
   cp .env.example .env
   nano .env
   ```

   **Important: Update these values in .env:**
   ```bash
   # Replace with your actual domain or IP
   DOMAIN_CLIENT=http://YOUR_DOMAIN_OR_IP
   DOMAIN_SERVER=http://YOUR_DOMAIN_OR_IP
   
   # Add your API keys
   OPENAI_API_KEY=your_openai_key_here
   ANTHROPIC_API_KEY=your_anthropic_key_here
   
   # Set strong secrets
   JWT_SECRET=your_super_secret_jwt_key_here
   JWT_REFRESH_SECRET=your_super_secret_refresh_key_here
   ```

6. **Create necessary directories:**
   ```bash
   mkdir -p uploads logs images shared
   chmod -R 755 .
   ```

7. **Deploy with production configuration:**
   ```bash
   docker-compose -f deploy-compose.yml pull
   docker-compose -f deploy-compose.yml up -d
   ```

8. **Monitor deployment:**
   ```bash
   # Check container status
   docker-compose -f deploy-compose.yml ps
   
   # View logs
   docker-compose -f deploy-compose.yml logs -f
   ```

## Step 5: Verify Deployment

1. **Check if containers are running:**
   ```bash
   docker-compose -f deploy-compose.yml ps
   ```

2. **Test the application:**
   - Open your browser and go to `http://YOUR_DOMAIN_OR_IP`
   - You should see the LibreChat interface

3. **Check logs for any errors:**
   ```bash
   docker-compose -f deploy-compose.yml logs api
   ```

## Step 6: Set Up SSL (Optional but Recommended)

For production, set up SSL with Let's Encrypt:

```bash
# Install Certbot
sudo apt update
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Update .env file
nano .env
# Change to:
# DOMAIN_CLIENT=https://your-domain.com
# DOMAIN_SERVER=https://your-domain.com

# Restart containers
docker-compose -f deploy-compose.yml restart
```

## Troubleshooting

### Common Issues:

1. **Containers not starting:**
   ```bash
   docker-compose -f deploy-compose.yml logs
   ```

2. **Port conflicts:**
   ```bash
   sudo netstat -tulpn | grep :3080
   sudo netstat -tulpn | grep :80
   ```

3. **Permission issues:**
   ```bash
   sudo chown -R $USER:$USER /opt/librechat
   chmod -R 755 /opt/librechat
   ```

4. **Database issues:**
   ```bash
   docker-compose -f deploy-compose.yml exec mongodb mongo --eval "db.stats()"
   ```

### Reset Everything:
```bash
cd /opt/librechat
docker-compose -f deploy-compose.yml down -v
docker system prune -a -f
docker-compose -f deploy-compose.yml up -d
```

## Maintenance Commands

```bash
# Update deployment
cd /opt/librechat
git pull origin main
docker-compose -f deploy-compose.yml down
docker-compose -f deploy-compose.yml pull
docker-compose -f deploy-compose.yml up -d

# View logs
docker-compose -f deploy-compose.yml logs -f

# Backup database
docker exec chat-mongodb mongodump --out /data/backup

# Restart services
docker-compose -f deploy-compose.yml restart
```

## 🎉 Success!

Once deployed, your LibreChat will be available with:
- ✅ Custom MCP servers (Docker, EDGAR SEC, Cloudflare, etc.)
- ✅ Production-ready configuration
- ✅ Nginx frontend
- ✅ MongoDB database
- ✅ Meilisearch for enhanced search
- ✅ All your customizations

**Your LibreChat deployment is now ready for production use!**