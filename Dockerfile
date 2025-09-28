FROM node:22-slim

# Install Chrome and dependencies
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    unzip \
    curl \
    xvfb \
    ca-certificates \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libc6 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgbm1 \
    libgcc1 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libxss1 \
    libxtst6 \
    lsb-release \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Install chrome-devtools-mcp globally
RUN npm install -g chrome-devtools-mcp@latest

# Create a non-root user for security
RUN groupadd -r chrome && useradd -r -g chrome -G audio,video chrome \
    && mkdir -p /home/chrome/Downloads /home/chrome/.cache \
    && chown -R chrome:chrome /home/chrome

# Create chrome data directory
RUN mkdir -p /tmp/chrome-data && chown -R chrome:chrome /tmp/chrome-data

# Expose the Chrome debugging port
EXPOSE 9222

# Switch to chrome user
USER chrome

# Set environment variables
ENV CHROME_DEBUG_PORT=9222
ENV DISPLAY=:99
ENV CHROME_BIN=/usr/bin/google-chrome
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:9222/json/version || exit 1

# Start Chrome with debugging enabled
CMD ["google-chrome", \
     "--remote-debugging-address=0.0.0.0", \
     "--remote-debugging-port=9222", \
     "--headless", \
     "--no-sandbox", \
     "--disable-dev-shm-usage", \
     "--disable-gpu", \
     "--disable-web-security", \
     "--disable-features=VizDisplayCompositor", \
     "--user-data-dir=/tmp/chrome-data", \
     "--window-size=1920,1080", \
     "about:blank"]
