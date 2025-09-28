# Troubleshooting Guide

## Common Issues and Solutions

### 1. Chrome Container Won't Start

**Symptoms:**
- Container exits immediately
- "chrome exited with code 1"

**Solutions:**
```bash
# Check container logs
docker-compose logs chrome

# Try with more memory
docker-compose down
# Edit docker-compose.yml to add: shm_size: 2gb
docker-compose up -d

# Check disk space
df -h
```

### 2. Port 9222 Already in Use

**Symptoms:**
- "Port 9222 is already allocated"

**Solutions:**
```bash
# Find what's using the port
lsof -i :9222
sudo netstat -tulpn | grep 9222

# Kill the process
sudo kill -9 <PID>

# Or use a different port
# Edit docker-compose.yml: "9223:9222"
# Update Claude config: --browserUrl=http://localhost:9223
```

### 3. Cannot Access Chrome Debugging Endpoint

**Symptoms:**
- `curl http://localhost:9222/json/version` fails
- Connection refused errors

**Solutions:**
```bash
# Check if container is running
docker-compose ps

# Restart container
docker-compose restart chrome

# Check network connectivity
docker exec -it chrome-devtools-mcp_chrome_1 curl http://localhost:9222/json/version

# Try different approach
docker-compose down
docker-compose up -d --force-recreate
```

### 4. MCP Server Connection Issues

**Symptoms:**
- Claude can't connect to MCP server
- "Server not found" errors

**Solutions:**
```bash
# Test MCP server manually
npx chrome-devtools-mcp@latest --browserUrl=http://localhost:9222

# Reinstall MCP package
npm uninstall -g chrome-devtools-mcp
npm install -g chrome-devtools-mcp@latest

# Check Node.js version (needs 22+)
node --version
```

### 5. Claude Desktop Not Connecting

**Symptoms:**
- Claude doesn't respond to browser commands
- MCP server not listed in Claude

**Solutions:**
```bash
# Verify config file location
# macOS/Linux: ~/.config/claude/claude_desktop_config.json
# Windows: %APPDATA%\Claude\claude_desktop_config.json

# Check config syntax
cat ~/.config/claude/claude_desktop_config.json | python3 -m json.tool

# Restart Claude Desktop completely
# Quit application, then reopen

# Check Claude Desktop logs (macOS)
tail -f ~/Library/Logs/Claude/claude_desktop.log
```

### 6. Permission Denied Errors

**Symptoms:**
- Docker permission errors
- Cannot write to directories

**Solutions:**
```bash
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in

# Fix Docker socket permissions
sudo chmod 666 /var/run/docker.sock

# For setup script
chmod +x setup.sh
chmod +x test.sh
```

### 7. Chrome Crashes or Becomes Unresponsive

**Symptoms:**
- Chrome container stops responding
- High memory usage

**Solutions:**
```bash
# Increase shared memory
# In docker-compose.yml:
# shm_size: 2gb

# Add memory limits
# In docker-compose.yml:
# mem_limit: 4g

# Restart container
docker-compose restart chrome

# Clear Chrome data
docker-compose down -v
docker-compose up -d
```

### 8. Network Issues in Docker

**Symptoms:**
- Cannot reach external websites
- DNS resolution failures

**Solutions:**
```bash
# Check Docker network
docker network ls
docker network inspect chrome-devtools-mcp-docker_default

# Use host networking (less secure)
# In docker-compose.yml:
# network_mode: host

# Add DNS servers
# In docker-compose.yml:
# dns:
#   - 8.8.8.8
#   - 1.1.1.1
```

## Quick Diagnostic Commands

```bash
# Run full test suite
./test.sh

# Check everything is running
docker-compose ps
curl http://localhost:9222/json/version

# View real-time logs
docker-compose logs -f chrome

# Get into container for debugging
docker-compose exec chrome bash

# Check Chrome processes
docker-compose exec chrome ps aux | grep chrome

# Test MCP connection
timeout 5s npx chrome-devtools-mcp@latest --browserUrl=http://localhost:9222 --help
```

## Getting Help

If none of these solutions work:

1. Run `./test.sh` and share the output
2. Include your system info:
   - OS and version
   - Docker version: `docker --version`
   - Docker Compose version: `docker-compose --version`
   - Node.js version: `node --version`
3. Share relevant logs:
   - Container logs: `docker-compose logs chrome`
   - Claude Desktop logs (if applicable)
4. Create an issue at: https://github.com/avi686/chrome-devtools-mcp-docker/issues
