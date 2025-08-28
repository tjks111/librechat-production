#!/bin/bash

# LibreChat Production Deployment Script for Digital Ocean
# This script automates the deployment process

set -e

echo "🚀 LibreChat Production Deployment Script"
echo "==========================================="

# Configuration
REPO_URL="https://github.com/tjks111/librechat-production.git"
APP_DIR="/opt/librechat"
BACKUP_DIR="/opt/librechat-backup-$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root for security reasons."
   exit 1
fi

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Please install Git first."
    exit 1
fi

print_status "All prerequisites met!"

# Stop existing containers if they exist
if [ -d "$APP_DIR" ]; then
    print_status "Stopping existing LibreChat containers..."
    cd $APP_DIR
    docker-compose -f deploy-compose.yml down || true
    
    # Create backup
    print_status "Creating backup of existing installation..."
    sudo cp -r $APP_DIR $BACKUP_DIR
    print_status "Backup created at: $BACKUP_DIR"
fi

# Create application directory
print_status "Setting up application directory..."
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR

# Clone or update repository
if [ -d "$APP_DIR/.git" ]; then
    print_status "Updating existing repository..."
    cd $APP_DIR
    git fetch origin
    git reset --hard origin/main
else
    print_status "Cloning repository..."
    git clone $REPO_URL $APP_DIR
    cd $APP_DIR
fi

# Set up environment file
print_status "Setting up environment configuration..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    print_warning "Please edit .env file with your production settings before continuing."
    print_warning "Update DOMAIN_CLIENT and DOMAIN_SERVER with your actual domain/IP."
    read -p "Press Enter after you've configured the .env file..."
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p uploads logs images shared

# Set proper permissions
print_status "Setting proper permissions..."
sudo chown -R $USER:$USER .
chmod -R 755 .

# Build and start containers
print_status "Starting LibreChat with production configuration..."
docker-compose -f deploy-compose.yml pull
docker-compose -f deploy-compose.yml up -d

# Wait for containers to start
print_status "Waiting for containers to start..."
sleep 30

# Check container status
print_status "Checking container status..."
docker-compose -f deploy-compose.yml ps

# Show logs
print_status "Showing recent logs..."
docker-compose -f deploy-compose.yml logs --tail=50

print_status "Deployment completed!"
print_status "LibreChat should be available at: http://YOUR_DOMAIN_OR_IP"
print_status "To view logs: docker-compose -f deploy-compose.yml logs -f"
print_status "To stop: docker-compose -f deploy-compose.yml down"

echo "==========================================="
echo "🎉 LibreChat deployment finished!"