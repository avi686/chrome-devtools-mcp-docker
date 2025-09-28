#!/bin/bash

# Chrome DevTools MCP Docker Setup Script
set -e

echo "🚀 Setting up Chrome DevTools MCP with Docker..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_warning "Node.js is not installed. Installing Node.js 22..."
    
    # Install Node.js based on OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew install node@22
        else
            print_error "Please install Node.js 22+ manually from https://nodejs.org/"
            exit 1
        fi
    else
        print_error "Please install Node.js 22+ manually from https://nodejs.org/"
        exit 1
    fi
fi

# Check Node.js version
NODE_VERSION=$(node --version | sed 's/v//' | cut -d. -f1)
if [ "$NODE_VERSION" -lt 22 ]; then
    print_error "Node.js version 22 or higher is required. Current version: $(node --version)"
    exit 1
fi

print_success "Node.js $(node --version) is installed"

# Install chrome-devtools-mcp
print_status "Installing chrome-devtools-mcp..."
npm install -g chrome-devtools-mcp@latest
print_success "chrome-devtools-mcp installed"

# Start Docker containers
print_status "Starting Chrome container with Docker Compose..."
docker-compose up -d

# Wait for Chrome to be ready
print_status "Waiting for Chrome to be ready..."
sleep 10

# Test Chrome debugging endpoint
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -f http://localhost:9222/json/version &> /dev/null; then
        print_success "Chrome debugging endpoint is ready!"
        break
    fi
    
    RETRY_COUNT=$((RETRY_COUNT + 1))
    print_status "Waiting for Chrome... (attempt $RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    print_error "Chrome failed to start properly"
    print_status "Checking container logs..."
    docker-compose logs chrome
    exit 1
fi

# Display Chrome version info
print_status "Chrome debugging info:"
curl -s http://localhost:9222/json/version | python3 -m json.tool || echo "Chrome is running but version info unavailable"

# Create Claude Desktop configuration
print_status "Creating Claude Desktop MCP configuration..."

# Determine Claude config path based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    CLAUDE_CONFIG_PATH="$HOME/.config/claude/claude_desktop_config.json"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CLAUDE_CONFIG_PATH="$HOME/.config/claude/claude_desktop_config.json"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    CLAUDE_CONFIG_PATH="$APPDATA/Claude/claude_desktop_config.json"
else
    print_warning "Unknown OS. Please manually configure Claude Desktop."
    CLAUDE_CONFIG_PATH=""
fi

if [ -n "$CLAUDE_CONFIG_PATH" ]; then
    # Create config directory if it doesn't exist
    mkdir -p "$(dirname "$CLAUDE_CONFIG_PATH")"
    
    # Create or update Claude Desktop config
    cat > "$CLAUDE_CONFIG_PATH" << 'EOF'
{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest",
        "--browserUrl=http://localhost:9222"
      ]
    }
  }
}
EOF
    
    print_success "Claude Desktop configuration created at: $CLAUDE_CONFIG_PATH"
else
    print_warning "Please manually add the following to your Claude Desktop config:"
    echo '{
  "mcpServers": {
    "chrome-devtools": {
      "command": "npx",
      "args": [
        "chrome-devtools-mcp@latest",
        "--browserUrl=http://localhost:9222"
      ]
    }
  }
}'
fi

# Test MCP server connection
print_status "Testing MCP server connection..."
timeout 10s npx chrome-devtools-mcp@latest --browserUrl=http://localhost:9222 --help &> /dev/null || print_warning "MCP server test inconclusive"

print_success "Setup completed successfully! 🎉"
echo ""
echo "Next steps:"
echo "1. Restart Claude Desktop completely (quit and reopen)"
echo "2. Test with Claude by asking: 'Navigate to https://google.com and tell me what you see'"
echo ""
echo "Useful commands:"
echo "  - Check Chrome status: curl http://localhost:9222/json/version"
echo "  - View container logs: docker-compose logs chrome"
echo "  - Stop containers: docker-compose down"
echo "  - Restart containers: docker-compose restart"
echo ""
echo "Chrome debugging endpoint: http://localhost:9222"
echo "Claude Desktop config: $CLAUDE_CONFIG_PATH"
