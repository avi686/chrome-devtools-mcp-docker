# Chrome DevTools MCP Docker Setup

A dockerized Chrome browser with DevTools protocol support for Claude Desktop MCP (Model Context Protocol) integration. This setup allows Claude to navigate websites, take screenshots, and interact with web pages.

## ✅ Current Status

Your Chrome DevTools setup is **WORKING**! The browserless/chrome container is running and accessible on port 9222.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- Node.js 22+ installed (on Windows for Claude Desktop)
- Claude Desktop application

### Setup Steps

1. **Clone and start the Docker container:**
```bash
git clone https://github.com/avi686/chrome-devtools-mcp-docker.git
cd chrome-devtools-mcp-docker
docker-compose up -d
```

2. **Configure Claude Desktop (Windows/WSL users):**
```bash
# Run from WSL
git pull  # Get latest scripts
chmod +x setup-claude-windows.sh
./setup-claude-windows.sh
```

3. **Install chrome-devtools-mcp on Windows:**
Open Windows PowerShell or Command Prompt (not WSL) and run:
```powershell
npm install -g chrome-devtools-mcp@latest
```

4. **Restart Claude Desktop:**
- Completely close Claude Desktop (check system tray)
- Start Claude Desktop again
- Look for the 🔧 tools icon to verify MCP is loaded

## 🧪 Testing

### Test Docker Setup
```bash
./test.sh
```

### Test with Claude
Ask Claude: "Navigate to https://google.com and tell me what you see"

### Manual Testing
```bash
# Check if Chrome is running
curl http://localhost:9222/json/version

# View active tabs
curl http://localhost:9222/json/list

# Check health
curl http://localhost:9222/health
```

## 📁 Configuration

### Claude Desktop Config Location
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`
- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Linux**: `~/.config/claude/claude_desktop_config.json`

### Configuration Content
```json
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
```

## 🛠️ Troubleshooting

### Chrome container won't start
```bash
# Clean up and restart
docker-compose down -v
docker system prune -f
docker-compose pull
docker-compose up -d
```

### MCP not showing in Claude
1. Ensure Node.js is installed on Windows (not just WSL)
2. Install chrome-devtools-mcp globally on Windows
3. Check Claude logs: `%APPDATA%\Claude\logs`
4. Verify config file exists at correct location

### Port 9222 already in use
```bash
# Find what's using the port
lsof -i :9222  # Linux/Mac
netstat -ano | findstr :9222  # Windows

# Change port in docker-compose.yml if needed
```

### WSL-specific issues
- Make sure Docker Desktop is running with WSL2 integration
- Chrome runs in WSL Docker, but Claude Desktop reads config from Windows
- Install Node.js and chrome-devtools-mcp on Windows side

## 📊 Architecture

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│ Claude Desktop  │────▶│ chrome-      │────▶│ Browserless     │
│   (Windows)     │ MCP │ devtools-mcp │ CDP │ Chrome          │
│                 │     │  (Node.js)   │     │ (Docker:9222)   │
└─────────────────┘     └──────────────┘     └─────────────────┘
```

## 🔧 Useful Commands

```bash
# View container logs
docker-compose logs -f chrome

# Restart container
docker-compose restart

# Stop container
docker-compose down

# Update to latest
git pull
docker-compose pull
docker-compose up -d

# Check what's running
docker-compose ps
```

## 🎯 What Claude Can Do

With this setup, Claude can:
- Navigate to websites and inspect them
- Take screenshots of web pages  
- Analyze page performance and loading times
- Inspect network requests and responses
- Debug JavaScript errors in the console
- Test responsive designs at different screen sizes
- Automate form filling and user interactions
- Extract data from web pages
- Monitor real-time changes on websites

## 📚 Resources

- [Chrome DevTools Protocol](https://chromedevtools.github.io/devtools-protocol/)
- [Browserless Documentation](https://www.browserless.io/docs)
- [MCP Documentation](https://docs.anthropic.com/mcp)
- [Claude Desktop](https://claude.ai/download)

## 🐛 Known Issues

1. Health endpoint shows as failed but Chrome still works (cosmetic issue)
2. Some Chrome errors in logs are normal (DBus, GCM) and don't affect functionality

## ✨ Features

- ✅ Headless Chrome in Docker
- ✅ Chrome DevTools Protocol on port 9222
- ✅ WebSocket support for real-time interaction
- ✅ Automatic restart on failure
- ✅ Health monitoring
- ✅ WSL2 compatible
- ✅ Resource efficient

## 🔒 Security Note

This exposes Chrome debugging on port 9222. Only use on trusted networks or localhost.

## 📝 License

MIT

## 🤝 Contributing

Pull requests welcome! Please test changes with `./test.sh` before submitting.

---

**Status**: System is operational and ready for use with Claude Desktop! 🎉
