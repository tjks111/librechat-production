#!/bin/bash

# LibreChat MCP Server Setup Script
echo "Setting up LibreChat MCP servers..."

# Ensure required directories exist
mkdir -p shared uploads logs .config/.wrangler/config

# Set proper permissions for Docker
chmod 755 shared uploads logs .config

# Install Python dependencies for MCP Edgar SEC
if [ -f "mcp_edgar_requirements.txt" ]; then
    echo "Installing MCP Edgar SEC dependencies..."
    pip install -r mcp_edgar_requirements.txt
fi

# Install Python dependencies for Docker MCP
if [ -f "docker_mcp_requirements.txt" ]; then
    echo "Installing Docker MCP dependencies..."
    pip install -r docker_mcp_requirements.txt
fi

# Pre-install MCP server packages to speed up initialization
echo "Pre-installing MCP server packages..."

# Install filesystem server
npx -y @modelcontextprotocol/server-filesystem --help > /dev/null 2>&1 &

# Install Cloudflare server
npx -y @cloudflare/mcp-server-cloudflare --help > /dev/null 2>&1 &

# Install Notion server
npx -y @notionhq/notion-mcp-server --help > /dev/null 2>&1 &

# Install Docker MCP
uvx docker-mcp --help > /dev/null 2>&1 &

# Wait for installations to complete
wait

echo "MCP servers setup complete!"
echo "Now you can start LibreChat with: docker-compose up -d"
