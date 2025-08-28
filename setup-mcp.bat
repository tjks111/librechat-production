@echo off
echo Setting up LibreChat MCP servers...

rem Ensure required directories exist
if not exist "shared" mkdir "shared"
if not exist "uploads" mkdir "uploads"
if not exist "logs" mkdir "logs"
if not exist ".config" mkdir ".config"
if not exist ".config\.wrangler" mkdir ".config\.wrangler"
if not exist ".config\.wrangler\config" mkdir ".config\.wrangler\config"

rem Install Python dependencies for MCP Edgar SEC
if exist "mcp_edgar_requirements.txt" (
    echo Installing MCP Edgar SEC dependencies...
    pip install -r mcp_edgar_requirements.txt
)

rem Install Python dependencies for Docker MCP
if exist "docker_mcp_requirements.txt" (
    echo Installing Docker MCP dependencies...
    pip install -r docker_mcp_requirements.txt
)

rem Pre-install MCP server packages to speed up initialization
echo Pre-installing MCP server packages...

rem Install filesystem server
start /B npx -y @modelcontextprotocol/server-filesystem --help >nul 2>&1

rem Install Cloudflare server
start /B npx -y @cloudflare/mcp-server-cloudflare --help >nul 2>&1

rem Install Notion server
start /B npx -y @notionhq/notion-mcp-server --help >nul 2>&1

rem Install Docker MCP (if uvx is available)
where uvx >nul 2>&1
if %ERRORLEVEL% == 0 (
    start /B uvx docker-mcp --help >nul 2>&1
)

echo MCP servers setup complete!
echo Now you can start LibreChat with: docker-compose up -d
pause
