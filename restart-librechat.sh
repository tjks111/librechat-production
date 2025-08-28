#!/bin/bash

echo "🔧 LibreChat MCP Server Diagnostic & Restart Script"
echo "=================================================="

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if command_exists node; then
    echo "✅ Node.js: $(node --version)"
else
    echo "❌ Node.js not found. Please install Node.js first."
    exit 1
fi

if command_exists npm; then
    echo "✅ npm: $(npm --version)"
else
    echo "❌ npm not found."
fi

if command_exists python; then
    echo "✅ Python: $(python --version)"
elif command_exists python3; then
    echo "✅ Python: $(python3 --version)"
else
    echo "⚠️  Python not found. MCP servers may not work."
fi

if command_exists docker; then
    echo "✅ Docker: $(docker --version)"
else
    echo "❌ Docker not found. Please install Docker first."
    exit 1
fi

if command_exists docker-compose; then
    echo "✅ Docker Compose: $(docker-compose --version)"
else
    echo "❌ Docker Compose not found."
    exit 1
fi

echo ""
echo "🔍 Checking LibreChat configuration..."

# Check if required files exist
if [ -f "librechat.yaml" ]; then
    echo "✅ librechat.yaml exists"
else
    echo "❌ librechat.yaml not found"
    exit 1
fi

if [ -f ".env" ]; then
    echo "✅ .env exists"
else
    echo "❌ .env not found"
    exit 1
fi

if [ -f "docker-compose.override.yml" ]; then
    echo "✅ docker-compose.override.yml exists"
else
    echo "⚠️  docker-compose.override.yml not found (optional)"
fi

# Check if required directories exist
echo ""
echo "📁 Checking directories..."

for dir in "shared" "uploads" "logs" ".config"; do
    if [ -d "$dir" ]; then
        echo "✅ $dir/ exists"
    else
        echo "📁 Creating $dir/"
        mkdir -p "$dir"
        echo "✅ $dir/ created"
    fi
done

# Ensure .config/wrangler structure exists
if [ ! -f ".config/.wrangler/config/default.toml" ]; then
    echo "📁 Creating wrangler config structure..."
    mkdir -p ".config/.wrangler/config"
    cat > .config/.wrangler/config/default.toml << EOF
[api]
account_id = "470c49d8e5e5db8b7f65a184939c1c6b"
api_token = ""

[env]
production = ""
preview = ""

[kv]
binding = ""
EOF
    echo "✅ Wrangler config created"
fi

echo ""
echo "🧹 Cleaning up Docker containers..."
docker-compose down

echo ""
echo "🚀 Starting LibreChat with MCP servers..."
docker-compose up -d

echo ""
echo "⏳ Waiting for containers to start..."
sleep 10

echo ""
echo "📊 Checking container status..."
docker-compose ps

echo ""
echo "📝 Checking MCP server initialization logs..."
docker-compose logs api | grep -i "mcp\|initialized" | tail -20

echo ""
echo "✅ Setup complete! Check the logs above for any MCP server errors."
echo "🌐 LibreChat should be available at: http://localhost:3080"
echo ""
echo "🔧 If you see MCP server errors, run:"
echo "   docker-compose logs api | grep -i mcp"
