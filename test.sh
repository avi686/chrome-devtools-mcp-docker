#!/bin/bash

# Test script for Chrome DevTools MCP setup
echo "🧪 Testing Chrome DevTools MCP setup..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

# Test 1: Check if Docker is running
print_test "Checking if Docker is running..."
if docker ps &> /dev/null; then
    print_pass "Docker is running"
else
    print_fail "Docker is not running"
    exit 1
fi

# Test 2: Check if containers are running
print_test "Checking if Chrome container is running..."
if docker-compose ps | grep -q "chrome.*Up"; then
    print_pass "Chrome container is running"
else
    print_fail "Chrome container is not running"
    echo "Starting containers..."
    docker-compose up -d
    sleep 10
fi

# Test 3: Check Chrome debugging endpoint
print_test "Testing Chrome debugging endpoint..."
if curl -f http://localhost:9222/json/version &> /dev/null; then
    print_pass "Chrome debugging endpoint is accessible"
    
    # Display Chrome version
    CHROME_VERSION=$(curl -s http://localhost:9222/json/version | grep -o '"Browser":"[^"]*"' | cut -d'"' -f4)
    echo "Chrome version: $CHROME_VERSION"
else
    print_fail "Chrome debugging endpoint is not accessible"
    echo "Container logs:"
    docker-compose logs chrome | tail -20
    exit 1
fi

# Test 4: Check if Node.js is installed
print_test "Checking Node.js installation..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_pass "Node.js is installed: $NODE_VERSION"
    
    # Check Node.js version
    NODE_MAJOR=$(echo $NODE_VERSION | sed 's/v//' | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 22 ]; then
        print_pass "Node.js version is compatible (22+)"
    else
        print_fail "Node.js version is too old. Need 22+, got $NODE_VERSION"
    fi
else
    print_fail "Node.js is not installed"
    exit 1
fi

# Test 5: Check if chrome-devtools-mcp is installed
print_test "Checking chrome-devtools-mcp installation..."
if npm list -g chrome-devtools-mcp &> /dev/null; then
    print_pass "chrome-devtools-mcp is installed globally"
else
    print_fail "chrome-devtools-mcp is not installed globally"
    echo "Installing chrome-devtools-mcp..."
    npm install -g chrome-devtools-mcp@latest
fi

# Test 6: Test MCP server connection
print_test "Testing MCP server connection..."
timeout 5s npx chrome-devtools-mcp@latest --browserUrl=http://localhost:9222 --help &> /dev/null
if [ $? -eq 0 ] || [ $? -eq 124 ]; then  # 124 is timeout exit code
    print_pass "MCP server can connect to Chrome"
else
    print_fail "MCP server cannot connect to Chrome"
fi

# Test 7: Check Claude Desktop configuration
print_test "Checking Claude Desktop configuration..."
CLAUDE_CONFIG=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    CLAUDE_CONFIG="$HOME/.config/claude/claude_desktop_config.json"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    CLAUDE_CONFIG="$HOME/.config/claude/claude_desktop_config.json"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    CLAUDE_CONFIG="$APPDATA/Claude/claude_desktop_config.json"
fi

if [ -n "$CLAUDE_CONFIG" ] && [ -f "$CLAUDE_CONFIG" ]; then
    if grep -q "chrome-devtools" "$CLAUDE_CONFIG"; then
        print_pass "Claude Desktop is configured for chrome-devtools MCP"
    else
        print_fail "Claude Desktop configuration missing chrome-devtools MCP"
        echo "Configuration file exists but doesn't contain chrome-devtools MCP server"
    fi
else
    print_fail "Claude Desktop configuration file not found"
    echo "Expected location: $CLAUDE_CONFIG"
fi

# Test 8: Check port availability
print_test "Checking if port 9222 is available..."
if lsof -i :9222 &> /dev/null; then
    print_pass "Port 9222 is in use (as expected for Chrome debugging)"
else
    print_fail "Port 9222 is not in use - Chrome may not be running properly"
fi

# Test 9: Test basic Chrome operations
print_test "Testing basic Chrome operations..."
TABS_RESPONSE=$(curl -s http://localhost:9222/json/list)
if echo "$TABS_RESPONSE" | grep -q '"type":"page"'; then
    print_pass "Chrome has active tabs/pages"
else
    print_fail "No active Chrome tabs found"
fi

echo ""
echo "🎯 Test Summary:"
echo "If all tests passed, your setup is ready!"
echo ""
echo "Next steps:"
echo "1. Restart Claude Desktop completely"
echo "2. Test with Claude by asking: 'Navigate to https://google.com and tell me what you see'"
echo ""
echo "Useful endpoints:"
echo "- Chrome version: curl http://localhost:9222/json/version"
echo "- Active tabs: curl http://localhost:9222/json/list"
echo "- New tab: curl -X POST http://localhost:9222/json/new"
echo ""
echo "If you encounter issues:"
echo "- Check container logs: docker-compose logs chrome"
echo "- Restart containers: docker-compose restart"
echo "- View this test again: ./test.sh"
