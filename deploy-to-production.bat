@echo off
REM LibreChat Production Deployment Script for Digital Ocean (Windows)
REM This script automates the deployment process

echo 🚀 LibreChat Production Deployment Script
echo ===========================================

REM Configuration
set REPO_URL=https://github.com/tjks111/librechat-production.git
set APP_DIR=C:\librechat
set BACKUP_DIR=C:\librechat-backup-%date:~-4,4%%date:~-10,2%%date:~-7,2%-%time:~0,2%%time:~3,2%%time:~6,2%

echo [INFO] Checking prerequisites...

REM Check Docker
where docker >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker is not installed. Please install Docker first.
    pause
    exit /b 1
)

REM Check Docker Compose
where docker-compose >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

REM Check Git
where git >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Git is not installed. Please install Git first.
    pause
    exit /b 1
)

echo [INFO] All prerequisites met!

REM Stop existing containers if they exist
if exist "%APP_DIR%" (
    echo [INFO] Stopping existing LibreChat containers...
    cd /d %APP_DIR%
    docker-compose -f deploy-compose.yml down
    
    REM Create backup
    echo [INFO] Creating backup of existing installation...
    xcopy "%APP_DIR%" "%BACKUP_DIR%\" /E /I /H /Y
    echo [INFO] Backup created at: %BACKUP_DIR%
)

REM Create application directory
echo [INFO] Setting up application directory...
if not exist "%APP_DIR%" mkdir "%APP_DIR%"

REM Clone or update repository
if exist "%APP_DIR%\.git" (
    echo [INFO] Updating existing repository...
    cd /d %APP_DIR%
    git fetch origin
    git reset --hard origin/main
) else (
    echo [INFO] Cloning repository...
    git clone %REPO_URL% %APP_DIR%
    cd /d %APP_DIR%
)

REM Set up environment file
echo [INFO] Setting up environment configuration...
if not exist ".env" (
    copy .env.example .env
    echo [WARNING] Please edit .env file with your production settings.
    echo [WARNING] Update DOMAIN_CLIENT and DOMAIN_SERVER with your actual domain/IP.
    pause
)

REM Create necessary directories
echo [INFO] Creating necessary directories...
if not exist "uploads" mkdir "uploads"
if not exist "logs" mkdir "logs"
if not exist "images" mkdir "images"
if not exist "shared" mkdir "shared"

REM Build and start containers
echo [INFO] Starting LibreChat with production configuration...
docker-compose -f deploy-compose.yml pull
docker-compose -f deploy-compose.yml up -d

REM Wait for containers to start
echo [INFO] Waiting for containers to start...
timeout /t 30

REM Check container status
echo [INFO] Checking container status...
docker-compose -f deploy-compose.yml ps

REM Show logs
echo [INFO] Showing recent logs...
docker-compose -f deploy-compose.yml logs --tail=50

echo [INFO] Deployment completed!
echo [INFO] LibreChat should be available at: http://YOUR_DOMAIN_OR_IP
echo [INFO] To view logs: docker-compose -f deploy-compose.yml logs -f
echo [INFO] To stop: docker-compose -f deploy-compose.yml down

echo ===========================================
echo 🎉 LibreChat deployment finished!
pause