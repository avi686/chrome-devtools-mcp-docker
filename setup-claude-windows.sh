#!/bin/bash

# Setup script for Claude Desktop configuration on Windows via WSL
echo "📝 Setting up Claude Desktop configuration for chrome-devtools MCP..."

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect Windows user directory from WSL
WIN_USER=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r\n')
if [ -z "$WIN_USER" ]; then
    echo "Enter your Windows username:"
    read WIN_USER
fi

# Windows Claude config path (accessible from WSL)
CLAUDE_CONFIG="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude/claude_desktop_config.json"
CONFIG_DIR="/mnt/c/Users/$WIN_USER/AppData/Roaming/Claude"

echo -e "${YELLOW}Windows user:${NC} $WIN_USER"
echo -e "${YELLOW}Config path:${NC} $CLAUDE_CONFIG"

# Create directory if it doesn't exist
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Creating Claude config directory..."
    mkdir -p "$CONFIG_DIR"
fi

# Check if config exists and back it up
if [ -f "$CLAUDE_CONFIG" ]; then
    echo "Existing config found. Creating backup..."
    cp "$CLAUDE_CONFIG" "$CLAUDE_CONFIG.backup.$(date +%Y%m%d_%H%M%S)"
fi

# Create or update the configuration
cat > "$CLAUDE_CONFIG" << 'EOF'
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest",
        "--browserUrl=http://localhost:9222"
      ],
      "env": {}
    }
  }
}
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Claude Desktop configuration created successfully!"
    echo ""
    echo "Configuration written to:"
    echo "  $CLAUDE_CONFIG"
    echo ""
    echo "⚠️  IMPORTANT: Next steps:"
    echo "1. Close Claude Desktop completely (check system tray)"
    echo "2. Start Claude Desktop again"
    echo "3. Look for 'chrome-devtools' in the MCP tools icon (🔧)"
    echo "4. Test by asking Claude: 'Navigate to https://google.com and tell me what you see'"
    echo ""
    echo "If chrome-devtools doesn't appear:"
    echo "- Make sure Node.js is installed on Windows (not just WSL)"
    echo "- Install globally on Windows: npm install -g chrome-devtools-mcp@latest"
    echo "- Check Claude logs: %APPDATA%\Claude\logs"
else
    echo "❌ Failed to create configuration file"
    echo "You may need to create it manually at:"
    echo "  $CLAUDE_CONFIG"
fi

# Verify the configuration
echo ""
echo "📋 Current configuration:"
if [ -f "$CLAUDE_CONFIG" ]; then
    cat "$CLAUDE_CONFIG"
else
    echo "Configuration file not found!"
fi

# Test if Chrome is accessible from Windows
echo ""
echo "🧪 Testing Chrome accessibility from Windows..."
if curl -s http://localhost:9222/json/version > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Chrome DevTools is accessible on localhost:9222"
else
    echo "⚠️  Chrome DevTools not accessible. Make sure Docker container is running."
fi
