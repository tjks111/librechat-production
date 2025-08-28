@echo off
echo 🔧 LibreChat MCP Server Diagnostic & Restart Script
echo ==================================================

echo 📋 Checking prerequisites...

where node >nul 2>&1
if %ERRORLEVEL% == 0 (
    for /f "tokens=*" %%i in ('node --version') do echo ✅ Node.js: %%i
) else (
    echo ❌ Node.js not found. Please install Node.js first.
    pause
    exit /b 1
)

where npm >nul 2>&1
if %ERRORLEVEL% == 0 (
    for /f "tokens=*" %%i in ('npm --version') do echo ✅ npm: %%i
) else (
    echo ❌ npm not found.
)

where python >nul 2>&1
if %ERRORLEVEL% == 0 (
    for /f "tokens=*" %%i in ('python --version') do echo ✅ Python: %%i
) else (
    echo ⚠️  Python not found. MCP servers may not work.
)

where docker >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo ✅ Docker found
) else (
    echo ❌ Docker not found. Please install Docker first.
    pause
    exit /b 1
)

where docker-compose >nul 2>&1
if %ERRORLEVEL% == 0 (
    echo ✅ Docker Compose found
) else (
    echo ❌ Docker Compose not found.
    pause
    exit /b 1
)

echo.
echo 🔍 Checking LibreChat configuration...

if exist "librechat.yaml" (
    echo ✅ librechat.yaml exists
) else (
    echo ❌ librechat.yaml not found
    pause
    exit /b 1
)

if exist ".env" (
    echo ✅ .env exists
) else (
    echo ❌ .env not found
    pause
    exit /b 1
)

if exist "docker-compose.override.yml" (
    echo ✅ docker-compose.override.yml exists
) else (
    echo ⚠️  docker-compose.override.yml not found (optional)
)

echo.
echo 📁 Checking directories...

for %%d in (shared uploads logs .config) do (
    if exist "%%d" (
        echo ✅ %%d\ exists
    ) else (
        echo 📁 Creating %%d\
        mkdir "%%d"
        echo ✅ %%d\ created
    )
)

rem Ensure .config/wrangler structure exists
if not exist ".config\.wrangler\config\default.toml" (
    echo 📁 Creating wrangler config structure...
    mkdir ".config\.wrangler\config" 2>nul
    echo [api] > .config\.wrangler\config\default.toml
    echo account_id = "470c49d8e5e5db8b7f65a184939c1c6b" >> .config\.wrangler\config\default.toml
    echo api_token = "" >> .config\.wrangler\config\default.toml
    echo. >> .config\.wrangler\config\default.toml
    echo [env] >> .config\.wrangler\config\default.toml
    echo production = "" >> .config\.wrangler\config\default.toml
    echo preview = "" >> .config\.wrangler\config\default.toml
    echo. >> .config\.wrangler\config\default.toml
    echo [kv] >> .config\.wrangler\config\default.toml
    echo binding = "" >> .config\.wrangler\config\default.toml
    echo ✅ Wrangler config created
)

echo.
echo 🧹 Cleaning up Docker containers...
docker-compose down

echo.
echo 🚀 Starting LibreChat with MCP servers...
docker-compose up -d

echo.
echo ⏳ Waiting for containers to start...
timeout /t 15

echo.
echo 📊 Checking container status...
docker-compose ps

echo.
echo 📝 Checking MCP server initialization logs...
docker-compose logs api | findstr /i "mcp initialized"

echo.
echo ✅ Setup complete! Check the logs above for any MCP server errors.
echo 🌐 LibreChat should be available at: http://localhost:3080
echo.
echo 🔧 If you see MCP server errors, run:
echo    docker-compose logs api ^| findstr /i mcp
echo.
pause
