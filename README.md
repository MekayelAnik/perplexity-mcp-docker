# Perplexity MCP Server
### Multi-Architecture Docker Image for AI-Powered Web Search & Research

<div align="left">

<img alt="perplexity-mcp" src="https://img.shields.io/badge/Perplexity-MCP-7C3AED?style=for-the-badge&logo=perplexity&logoColor=white" width="400">

[![Docker Pulls](https://img.shields.io/docker/pulls/mekayelanik/perplexity-mcp.svg?style=flat-square)](https://hub.docker.com/r/mekayelanik/perplexity-mcp)
[![Docker Stars](https://img.shields.io/docker/stars/mekayelanik/perplexity-mcp.svg?style=flat-square)](https://hub.docker.com/r/mekayelanik/perplexity-mcp)
[![License](https://img.shields.io/badge/license-GPL-blue.svg?style=flat-square)](https://raw.githubusercontent.com/MekayelAnik/perplexity-mcp-docker/refs/heads/main/LICENSE)

**[NPM Package](https://www.npmjs.com/package/@perplexity-ai/mcp-server)** • **[GitHub Repository](https://github.com/mekayelanik/perplexity-mcp-docker)** • **[Docker Hub](https://hub.docker.com/r/mekayelanik/perplexity-mcp)**

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [MCP Client Setup](#mcp-client-setup)
- [Available Tools](#available-tools)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Resources & Support](#resources--support)

---

## Overview

Perplexity MCP Server brings real-time web search, advanced reasoning, and deep research capabilities to AI assistants through the official Perplexity API Platform. Powered by Sonar models and the Search API, it seamlessly integrates with VS Code, Cursor, Windsurf, Claude Desktop, and any MCP-compatible client.

### Key Features

✨ **Four Powerful Tools** - Search, Ask, Research, and Reason capabilities  
🔍 **Real-Time Web Search** - Access current information from across the internet  
🧠 **Advanced Reasoning** - Complex problem-solving with sonar-reasoning-pro  
📚 **Deep Research** - Comprehensive analysis with sonar-deep-research  
🚀 **Multiple Protocols** - HTTP, SSE, and WebSocket transport support  
🌐 **CORS Ready** - Built-in CORS support for browser-based clients  
⚡ **High Performance** - Optimized for speed and reliability  
🎯 **Zero Configuration** - Works with API key only  
🔧 **Highly Customizable** - Fine-tune models, temperature, tokens, and more  
📊 **Health Monitoring** - Built-in health check endpoint

### Supported Architectures

| Architecture | Status | Notes |
|:-------------|:------:|:------|
| **x86-64** | ✅ Stable | Intel/AMD processors |
| **ARM64** | ✅ Stable | Raspberry Pi, Apple Silicon |

### Available Tags

| Tag | Stability | Use Case |
|:----|:---------:|:---------|
| `stable` | ⭐⭐⭐ | **Production (recommended)** |
| `latest` | ⭐⭐⭐ | Latest stable features |
| `1.x.x` | ⭐⭐⭐ | Version pinning |
| `beta` | ⚠️ | Testing only |

---

## Quick Start

### Prerequisites

- Docker Engine 23.0+
- Perplexity API Key ([Get yours here](https://www.perplexity.ai/account/api/group))
- Network access for API communication

### Docker Compose (Recommended)

```yaml
services:
  perplexity-mcp:
    image: mekayelanik/perplexity-mcp:stable
    container_name: perplexity-mcp
    restart: unless-stopped
    ports:
      - "8050:8050"
    environment:
      # Required
      - PERPLEXITY_API_KEY=pplx-your-api-key-here
      
      # Optional Configuration
      - PERPLEXITY_DEFAULT_MODEL=sonar-pro
      - PERPLEXITY_MAX_TOKENS=4096
      - PERPLEXITY_TEMPERATURE=0.7
      - PERPLEXITY_SEARCH_RECENCY_FILTER=month
      
      # Server Settings
      - PORT=8050
      - PROTOCOL=SHTTP
      - CORS=*
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Dhaka
```

**Deploy:**

```bash
docker compose up -d
docker compose logs -f perplexity-mcp
```

### Docker CLI

```bash
docker run -d \
  --name=perplexity-mcp \
  --restart=unless-stopped \
  -p 8050:8050 \
  -e PERPLEXITY_API_KEY=pplx-your-api-key-here \
  -e PORT=8050 \
  -e PROTOCOL=SHTTP \
  mekayelanik/perplexity-mcp:stable
```

### Access Endpoints

| Protocol | Endpoint | Use Case |
|:---------|:---------|:---------|
| **HTTP** | `http://host-ip:8050/mcp` | **Recommended** |
| **SSE** | `http://host-ip:8050/sse` | Real-time streaming |
| **WebSocket** | `ws://host-ip:8050/message` | Bidirectional |
| **Health** | `http://host-ip:8050/healthz` | Monitoring |

> ⏱️ Server ready in 5-10 seconds after container start

---

## Configuration

### Environment Variables

#### Required Settings

| Variable | Required | Description |
|:---------|:--------:|:------------|
| `PERPLEXITY_API_KEY` | **✅ Yes** | Your Perplexity API key |

#### Model Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `PERPLEXITY_DEFAULT_MODEL` | `sonar-pro` | Default model for queries |
| `PERPLEXITY_MAX_TOKENS` | `4096` | Max tokens per response (1-131072) |
| `PERPLEXITY_TEMPERATURE` | `0.7` | Generation temperature (0-2) |

#### Search Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `PERPLEXITY_SEARCH_DOMAIN_FILTER` | _(none)_ | Comma-separated domains to search |
| `PERPLEXITY_SEARCH_RECENCY_FILTER` | `month` | Time filter: hour, day, week, month, year |
| `PERPLEXITY_RETURN_IMAGES` | `false` | Include images in search results |
| `PERPLEXITY_RETURN_RELATED_QUESTIONS` | `false` | Include related questions |

#### Server Configuration

| Variable | Default | Description |
|:---------|:-------:|:------------|
| `PORT` | `8050` | Server port (1-65535) |
| `PROTOCOL` | `SHTTP` | Transport protocol (SHTTP/SSE/WS) |
| `CORS` | _(none)_ | Cross-Origin configuration |
| `PUID` | `1000` | User ID for file permissions |
| `PGID` | `1000` | Group ID for file permissions |
| `TZ` | `Asia/Dhaka` | Container timezone |
| `DEBUG_MODE` | `false` | Enable debug mode |

### Getting Your API Key

1. Visit [Perplexity API Portal](https://www.perplexity.ai/account/api/group)
2. Sign up or log in to your account
3. Choose a plan (free tier available)
4. Generate a new API key
5. Copy the key and use it in your Docker configuration

### Available Models

| Model | Use Case | Context |
|:------|:---------|:-------:|
| **sonar-pro** | General-purpose with web search | 128K |
| **sonar-reasoning-pro** | Advanced reasoning & problem-solving | 128K |
| **sonar-deep-research** | Comprehensive research & analysis | 128K |
| **llama-3.1-sonar-small-128k-online** | Fast, lightweight queries | 128K |
| **llama-3.1-sonar-large-128k-online** | Balanced performance | 128K |
| **llama-3.1-sonar-huge-128k-online** | Maximum capability | 128K |

### Protocol Configuration

```yaml
# HTTP/Streamable HTTP (Recommended)
environment:
  - PROTOCOL=SHTTP

# Server-Sent Events
environment:
  - PROTOCOL=SSE

# WebSocket
environment:
  - PROTOCOL=WS
```

### CORS Configuration

```yaml
# Development - Allow all origins
environment:
  - CORS=*

# Production - Specific domains
environment:
  - CORS=https://example.com,https://app.example.com

# Mixed domains and IPs
environment:
  - CORS=https://example.com,192.168.1.100:3000

# Regex patterns
environment:
  - CORS=/^https:\/\/.*\.example\.com$/
```

> ⚠️ **Security:** Never use `CORS=*` in production environments

### Advanced Configuration Examples

#### Research-Optimized Setup

```yaml
environment:
  - PERPLEXITY_API_KEY=pplx-your-key
  - PERPLEXITY_DEFAULT_MODEL=sonar-deep-research
  - PERPLEXITY_MAX_TOKENS=8192
  - PERPLEXITY_TEMPERATURE=0.8
  - PERPLEXITY_SEARCH_RECENCY_FILTER=week
  - PERPLEXITY_RETURN_IMAGES=true
  - PERPLEXITY_RETURN_RELATED_QUESTIONS=true
```

#### Fast Response Setup

```yaml
environment:
  - PERPLEXITY_API_KEY=pplx-your-key
  - PERPLEXITY_DEFAULT_MODEL=llama-3.1-sonar-small-128k-online
  - PERPLEXITY_MAX_TOKENS=2048
  - PERPLEXITY_TEMPERATURE=0.5
  - PERPLEXITY_SEARCH_RECENCY_FILTER=day
```

#### Domain-Specific Search

```yaml
environment:
  - PERPLEXITY_API_KEY=pplx-your-key
  - PERPLEXITY_DEFAULT_MODEL=sonar-pro
  - PERPLEXITY_SEARCH_DOMAIN_FILTER=arxiv.org,github.com,stackoverflow.com
  - PERPLEXITY_SEARCH_RECENCY_FILTER=month
```

---

## MCP Client Setup

### Transport Compatibility

| Client | HTTP | SSE | WebSocket | Recommended |
|:-------|:----:|:---:|:---------:|:------------|
| **VS Code (Cline/Roo-Cline)** | ✅ | ✅ | ❌ | HTTP |
| **Claude Desktop** | ✅ | ✅ | ⚠️* | HTTP |
| **Cursor** | ✅ | ✅ | ⚠️* | HTTP |
| **Windsurf** | ✅ | ✅ | ⚠️* | HTTP |

> ⚠️ *WebSocket support is experimental

### VS Code (Cline/Roo-Cline)

Add to `.vscode/settings.json`:

```json
{
  "mcp.servers": {
    "perplexity": {
      "url": "http://host-ip:8050/mcp",
      "transport": "http",
      "autoApprove": [
        "perplexity_search",
        "perplexity_ask",
        "perplexity_research",
        "perplexity_reason"
      ]
    }
  }
}
```

### Claude Desktop

**Config Locations:**
- **Linux:** `~/.config/Claude/claude_desktop_config.json`
- **macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows:** `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "perplexity": {
      "transport": "http",
      "url": "http://localhost:8050/mcp"
    }
  }
}
```

### Cursor

Add to `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "perplexity": {
      "transport": "http",
      "url": "http://host-ip:8050/mcp"
    }
  }
}
```

### Windsurf (Codeium)

Add to `.codeium/mcp_settings.json`:

```json
{
  "mcpServers": {
    "perplexity": {
      "transport": "http",
      "url": "http://host-ip:8050/mcp"
    }
  }
}
```

### Claude Code

Add to `~/.config/claude-code/mcp_config.json`:

```json
{
  "mcpServers": {
    "perplexity": {
      "transport": "http",
      "url": "http://localhost:8050/mcp"
    }
  }
}
```

Or configure via CLI:

```bash
claude-code config mcp add perplexity \
  --transport http \
  --url http://localhost:8050/mcp
```

### GitHub Copilot CLI

Add to `~/.github-copilot/mcp.json`:

```json
{
  "mcpServers": {
    "perplexity": {
      "transport": "http",
      "url": "http://host-ip:8050/mcp"
    }
  }
}
```

---

## Available Tools

### 🔍 perplexity_search
Direct web search using the Perplexity Search API. Returns ranked search results with metadata, perfect for finding current information.

**Use Cases:**
- Finding recent news and articles
- Locating specific information across the web
- Getting ranked search results with relevance scores
- Quick information lookup

**Example Prompts:**
- "Search for the latest AI developments"
- "Find recent articles about climate change"
- "What are the top search results for quantum computing?"

---

### 💬 perplexity_ask
General-purpose conversational AI with real-time web search using the `sonar-pro` model. Great for quick questions and everyday searches.

**Use Cases:**
- Answering general questions with current data
- Quick fact-checking and verification
- Conversational search queries
- Getting summaries with citations

**Example Prompts:**
- "What's happening in the stock market today?"
- "Explain the latest developments in renewable energy"
- "Who won the recent elections?"

---

### 📚 perplexity_research
Deep, comprehensive research using the `sonar-deep-research` model. Ideal for thorough analysis and detailed reports.

**Use Cases:**
- In-depth topic analysis
- Comprehensive literature reviews
- Detailed market research
- Academic and professional research

**Example Prompts:**
- "Research the impact of AI on healthcare"
- "Give me a comprehensive analysis of electric vehicle market trends"
- "Research the history and future of space exploration"

---

### 🧠 perplexity_reason
Advanced reasoning and problem-solving using the `sonar-reasoning-pro` model. Perfect for complex analytical tasks.

**Use Cases:**
- Solving complex problems step-by-step
- Logical reasoning and analysis
- Mathematical and scientific calculations
- Strategic planning and decision-making

**Example Prompts:**
- "Reason through the implications of quantum computing on cryptography"
- "Analyze the pros and cons of different renewable energy sources"
- "What are the logical steps to solve this optimization problem?"

---

## Advanced Usage

### Production Configuration

```yaml
services:
  perplexity-mcp:
    image: mekayelanik/perplexity-mcp:stable
    container_name: perplexity-mcp
    restart: unless-stopped
    ports:
      - "8050:8050"
    environment:
      # Required
      - PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY}
      
      # Model Configuration
      - PERPLEXITY_DEFAULT_MODEL=sonar-pro
      - PERPLEXITY_MAX_TOKENS=4096
      - PERPLEXITY_TEMPERATURE=0.7
      
      # Search Settings
      - PERPLEXITY_SEARCH_RECENCY_FILTER=month
      - PERPLEXITY_RETURN_IMAGES=false
      - PERPLEXITY_RETURN_RELATED_QUESTIONS=false
      
      # Server Settings
      - PORT=8050
      - PROTOCOL=SHTTP
      - CORS=https://app.example.com
      - PUID=1000
      - PGID=1000
      - TZ=UTC
    
    # Resource limits
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
    
    # Health check
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "8050"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s
```

### Reverse Proxy Setup

#### Nginx

```nginx
server {
    listen 80;
    server_name perplexity.example.com;
    
    location / {
        proxy_pass http://localhost:8050;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts for API calls
        proxy_connect_timeout 60;
        proxy_send_timeout 60;
        proxy_read_timeout 60;
    }
}
```

#### Traefik

```yaml
services:
  perplexity-mcp:
    image: mekayelanik/perplexity-mcp:stable
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.perplexity-mcp.rule=Host(`perplexity.example.com`)"
      - "traefik.http.routers.perplexity-mcp.entrypoints=websecure"
      - "traefik.http.routers.perplexity-mcp.tls.certresolver=myresolver"
      - "traefik.http.services.perplexity-mcp.loadbalancer.server.port=8050"
```

### Multiple Instances for Different Use Cases

```yaml
services:
  # General purpose instance
  perplexity-mcp-general:
    image: mekayelanik/perplexity-mcp:stable
    container_name: perplexity-general
    ports:
      - "8050:8050"
    environment:
      - PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY}
      - PERPLEXITY_DEFAULT_MODEL=sonar-pro
      - PORT=8050
  
  # Research-focused instance
  perplexity-mcp-research:
    image: mekayelanik/perplexity-mcp:stable
    container_name: perplexity-research
    ports:
      - "8051:8050"
    environment:
      - PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY}
      - PERPLEXITY_DEFAULT_MODEL=sonar-deep-research
      - PERPLEXITY_MAX_TOKENS=8192
      - PERPLEXITY_RETURN_IMAGES=true
      - PERPLEXITY_RETURN_RELATED_QUESTIONS=true
      - PORT=8050
  
  # Fast response instance
  perplexity-mcp-fast:
    image: mekayelanik/perplexity-mcp:stable
    container_name: perplexity-fast
    ports:
      - "8052:8050"
    environment:
      - PERPLEXITY_API_KEY=${PERPLEXITY_API_KEY}
      - PERPLEXITY_DEFAULT_MODEL=llama-3.1-sonar-small-128k-online
      - PERPLEXITY_MAX_TOKENS=2048
      - PORT=8050
```

### Using Environment File

Create `.env` file:

```bash
PERPLEXITY_API_KEY=pplx-your-api-key-here
PERPLEXITY_DEFAULT_MODEL=sonar-pro
PERPLEXITY_MAX_TOKENS=4096
PERPLEXITY_TEMPERATURE=0.7
PORT=8050
PROTOCOL=SHTTP
CORS=https://example.com
```

Then use in docker-compose.yml:

```yaml
services:
  perplexity-mcp:
    image: mekayelanik/perplexity-mcp:stable
    env_file: .env
    ports:
      - "${PORT}:${PORT}"
```

---

## Troubleshooting

### Pre-Flight Checklist

- ✅ Docker 23.0+
- ✅ Valid Perplexity API key
- ✅ Port 8050 available
- ✅ Network connectivity to Perplexity API
- ✅ Latest stable image
- ✅ Correct environment variables

### Common Issues

**API Key Not Set**
```bash
# Error: PERPLEXITY_API_KEY environment variable is REQUIRED
# Solution: Set your API key
docker run -e PERPLEXITY_API_KEY=pplx-your-key-here ...
```

**Container Won't Start**
```bash
# Check logs for detailed error
docker logs perplexity-mcp

# Pull latest image
docker pull mekayelanik/perplexity-mcp:stable

# Restart container
docker restart perplexity-mcp
```

**Connection Refused**
```bash
# Verify container is running
docker ps | grep perplexity-mcp

# Check port binding
docker port perplexity-mcp

# Test health endpoint
curl http://localhost:8050/healthz
```

**Invalid Model Error**
```yaml
# Use a valid model name
environment:
  - PERPLEXITY_DEFAULT_MODEL=sonar-pro  # ✅ Valid
  # Not: PERPLEXITY_DEFAULT_MODEL=gpt-4  # ❌ Invalid
```

**API Rate Limiting**
```bash
# Check your API usage at:
# https://www.perplexity.ai/account/api/group

# Consider upgrading your plan for higher limits
```

**CORS Errors**
```yaml
# Development - allow all
environment:
  - CORS=*

# Production - specific origins
environment:
  - CORS=https://yourdomain.com
```

**Temperature Out of Range**
```yaml
# Must be between 0 and 2
environment:
  - PERPLEXITY_TEMPERATURE=0.7  # ✅ Valid
  # Not: PERPLEXITY_TEMPERATURE=3.0  # ❌ Invalid
```

**Max Tokens Error**
```yaml
# Must be between 1 and 131072
environment:
  - PERPLEXITY_MAX_TOKENS=4096  # ✅ Valid
  # Not: PERPLEXITY_MAX_TOKENS=999999  # ❌ Invalid
```

**Debug Mode**
```yaml
# Enable verbose debugging
environment:
  - DEBUG_MODE=verbose

# Then check logs
docker logs -f perplexity-mcp
```

### Health Check Testing

```bash
# Basic health check
curl http://localhost:8050/healthz

# Test MCP endpoint
curl http://localhost:8050/mcp

# View running configuration
docker logs perplexity-mcp | grep "CONFIGURATION"
```

### Validation Messages

The server provides helpful validation messages:

```bash
# ✅ Success messages
🔑 API Key: pplx-xxxx...xxxx (length: 40)
🚀 Launching Perplexity Ask MCP Server with protocol: SHTTP/streamableHttp on port: 8050

# ⚠️ Warning messages
⚠️ Warning: Unknown PERPLEXITY_DEFAULT_MODEL: 'invalid-model'
   Valid models: sonar-pro, sonar-reasoning-pro, sonar-deep-research
   Using default: sonar-pro

# ❌ Error messages
❌ ERROR: PERPLEXITY_API_KEY environment variable is REQUIRED
```

---

## Resources & Support

### Documentation
- 📦 [Official NPM Package](https://www.npmjs.com/package/@perplexity-ai/mcp-server)
- 📘 [DeepWiki Documentation](https://deepwiki.com/ppl-ai/modelcontextprotocol)
- 🐳 [Docker Hub](https://hub.docker.com/r/mekayelanik/perplexity-mcp)
- 🔧 [GitHub Repository](https://github.com/mekayelanik/perplexity-mcp)

### Perplexity Resources
- 🌐 [Perplexity API Portal](https://www.perplexity.ai/account/api/group)
- 💬 [Community Forum](https://community.perplexity.ai)
- 📚 [API Documentation](https://docs.perplexity.ai)

### MCP Resources
- 📘 [MCP Protocol Specification](https://modelcontextprotocol.io)
- 🎓 [MCP Documentation](https://modelcontextprotocol.io/docs)
- 💬 [MCP Community](https://discord.gg/mcp)

### Getting Help

**Docker Image Issues:**
- [GitHub Issues](https://github.com/mekayelanik/perplexity-mcp/issues)
- [Discussions](https://github.com/mekayelanik/perplexity-mcp/discussions)

**API & Tool Questions:**
- Check logs: `docker logs perplexity-mcp`
- Test health: `curl http://localhost:8050/healthz`
- Visit [DeepWiki](https://deepwiki.com/ppl-ai/modelcontextprotocol)
- Community: [community.perplexity.ai](https://community.perplexity.ai)

### Updating

```bash
# Docker Compose
docker compose pull
docker compose up -d

# Docker CLI
docker pull mekayelanik/perplexity-mcp:stable
docker stop perplexity-mcp
docker rm perplexity-mcp
# Re-run your docker run command
```

### Version Pinning

```yaml
# Use specific version
services:
  perplexity-mcp:
    image: mekayelanik/perplexity-mcp:1.0.9

# Or use stable tag (recommended)
services:
  perplexity-mcp:
    image: mekayelanik/perplexity-mcp:stable
```

---

## Performance Tips

### Optimize for Speed

```yaml
environment:
  - PERPLEXITY_DEFAULT_MODEL=llama-3.1-sonar-small-128k-online
  - PERPLEXITY_MAX_TOKENS=2048
  - PERPLEXITY_TEMPERATURE=0.5
```

### Optimize for Quality

```yaml
environment:
  - PERPLEXITY_DEFAULT_MODEL=sonar-deep-research
  - PERPLEXITY_MAX_TOKENS=8192
  - PERPLEXITY_TEMPERATURE=0.8
  - PERPLEXITY_RETURN_IMAGES=true
  - PERPLEXITY_RETURN_RELATED_QUESTIONS=true
```

### Resource Limits

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 1G
    reservations:
      cpus: '1.0'
      memory: 512M
```

---

## Security Best Practices

1. **Protect Your API Key**
   - Never commit API keys to version control
   - Use environment files or secrets management
   - Rotate keys regularly

2. **Network Security**
   - Never use `CORS=*` in production
   - Use HTTPS with reverse proxy
   - Implement rate limiting

3. **Container Security**
   - Run as non-root user (default PUID/PGID)
   - Keep Docker image updated
   - Use specific version tags for production

4. **Monitoring**
   - Monitor API usage and costs
   - Set up logging and alerting
   - Track health check status

5. **Access Control**
   - Use reverse proxy authentication
   - Implement IP whitelisting if needed
   - Monitor access logs

---

## API Costs & Limits

Perplexity API pricing varies by plan:

- **Free Tier**: Limited requests per month
- **Paid Plans**: Higher rate limits and quotas

Check current pricing at: [https://www.perplexity.ai/account/api/group](https://www.perplexity.ai/account/api/group)

Monitor your usage to avoid unexpected costs.

---

## License

GPL License - See [LICENSE](https://raw.githubusercontent.com/MekayelAnik/perplexity-mcp-docker/refs/heads/main/LICENSE) for details.

**Disclaimer:** Unofficial Docker image for [@perplexity-ai/mcp-server](https://www.npmjs.com/package/@perplexity-ai/mcp-server). Users are responsible for compliance with Perplexity API terms of service and applicable laws.

---

<div align="center">

[Report Bug](https://github.com/mekayelanik/perplexity-mcp-docker/issues) • [Request Feature](https://github.com/mekayelanik/perplexity-mcp-docker/issues) • [Contribute](https://github.com/mekayelanik/perplexity-mcp-docker/pulls)

</div>