# Chrome DevTools MCP Docker Setup

A complete Docker-based setup for connecting Chrome DevTools with Claude AI using the Model Context Protocol (MCP). This allows Claude to control and inspect a live Chrome browser for debugging, performance analysis, and web automation.

## 🚀 Quick Start

### One-Command Setup

```bash
git clone https://github.com/avi686/chrome-devtools-mcp-docker.git
cd chrome-devtools-mcp-docker
chmod +x setup.sh
./setup.sh
```

## 🧪 Testing

Test your setup by asking Claude:

```
Navigate to https://google.com and tell me what you see
```

## 📁 Project Structure

```
chrome-devtools-mcp-docker/
├── docker-compose.yml    # Main Docker Compose configuration
├── Dockerfile           # Custom Chrome image with MCP support  
├── setup.sh            # Automated setup script
└── README.md           # This file
```

## 🔧 Manual Setup

1. **Start Chrome container:**
   ```bash
   docker-compose up -d
   ```

2. **Install chrome-devtools-mcp:**
   ```bash
   npm install -g chrome-devtools-mcp@latest
   ```

3. **Configure Claude Desktop:**
   
   Add this to `~/.config/claude/claude_desktop_config.json`:

   ```json
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
   ```

4. **Restart Claude Desktop** completely

## 🛠️ Troubleshooting

**Check Chrome status:**
```bash
curl http://localhost:9222/json/version
```

**View logs:**
```bash
docker-compose logs chrome
```

**Restart containers:**
```bash
docker-compose restart chrome
```

## 🎯 What Claude Can Do

With this setup, I (Claude) can:
- Navigate to websites and inspect them
- Take screenshots of web pages
- Analyze page performance and loading times
- Inspect network requests and responses
- Debug JavaScript errors in the console
- Test responsive designs at different screen sizes
- Automate form filling and user interactions

## 🔒 Security Note

This exposes Chrome debugging on port 9222. Only use on trusted networks or localhost.

## 📞 Support

If you encounter issues, check the logs with `docker-compose logs chrome` or create an issue in this repository.

---

Made with ❤️ for AI automation
