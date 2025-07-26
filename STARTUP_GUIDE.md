# Open WebUI Startup Guide 🚀

A comprehensive guide to start the Open WebUI service using different methods based on your needs.

## Overview

Open WebUI is a self-hosted AI platform that combines:
- **Frontend**: Svelte/SvelteKit with TypeScript (runs on port 5173 in dev, built into static files for production)
- **Backend**: Python FastAPI application (runs on port 8080)
- **Database**: SQLAlchemy with support for SQLite, PostgreSQL, MySQL
- **AI Integration**: Compatible with Ollama, OpenAI API, and other LLM providers

## Quick Start Options

### 🐳 Method 1: Docker (Recommended for most users)

The simplest way to get started. Choose based on your setup:

#### Option A: With Ollama on your computer
```bash
docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

#### Option B: With Ollama on a different server
```bash
docker run -d -p 3000:8080 \
  -e OLLAMA_BASE_URL=https://your-ollama-server.com \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

#### Option C: OpenAI API only
```bash
docker run -d -p 3000:8080 \
  -e OPENAI_API_KEY=your_secret_key \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

#### Option D: With GPU support
```bash
docker run -d -p 3000:8080 \
  --gpus all \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:cuda
```

**Access**: Open http://localhost:3000

### 🐍 Method 2: Python pip (For simple deployment)

**Requirements**: Python 3.11+

```bash
# Install
pip install open-webui

# Start the service
open-webui serve
```

**Access**: Open http://localhost:8080

### 🏗️ Method 3: Docker Compose (Advanced configurations)

Best for production deployments or when you need specific configurations.

#### Basic setup with Ollama
```bash
# Use the provided compose script for easy setup
./run-compose.sh

# Or manual docker-compose
docker compose up -d
```

#### Advanced configurations
```bash
# With GPU support
./run-compose.sh --enable-gpu[count=1]

# With API exposure
./run-compose.sh --enable-api[port=11435]

# With custom data directory
./run-compose.sh --data[folder=./ollama-data]

# Combined example
./run-compose.sh --enable-gpu[count=1] --enable-api[port=11435] --webui[port=3000] --data[folder=./my-data]

# With Playwright for web scraping
./run-compose.sh --playwright

# Build custom image
./run-compose.sh --build

# Drop/stop everything
./run-compose.sh --drop
```

**Access**: Open http://localhost:3000 (or your specified port)

### 💻 Method 4: Development Setup (For contributors)

Set up both frontend and backend for development.

#### Prerequisites
- **Node.js**: 18.13.0 - 22.x.x
- **npm**: 6.0.0+
- **Python**: 3.11+
- **Git**

#### Backend Setup
```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start backend (with auto-reload)
./dev.sh
# Or manually:
# export CORS_ALLOW_ORIGIN=http://localhost:5173
# uvicorn open_webui.main:app --port 8080 --host 0.0.0.0 --reload
```

Backend will be available at http://localhost:8080

#### Frontend Setup (New terminal)
```bash
# From project root
npm install

# Start development server
npm run dev
# Or on specific port:
# npm run dev:5050
```

Frontend will be available at http://localhost:5173

#### Development Commands
```bash
# Build for production
npm run build

# Build and watch for changes
npm run build:watch

# Run type checking
npm run check

# Run linting
npm run lint

# Format code
npm run format

# Run tests
npm run test:frontend

# Run Cypress tests
npm run cy:open
```

## Environment Variables

### Common Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `OLLAMA_BASE_URL` | Ollama server URL | `http://localhost:11434` |
| `OPENAI_API_KEY` | OpenAI API key | - |
| `WEBUI_SECRET_KEY` | Secret key for sessions | Auto-generated |
| `PORT` | Backend port | `8080` |
| `CORS_ALLOW_ORIGIN` | CORS origins | `*` |

### Database Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_URL` | Database connection string | SQLite |
| `POSTGRES_HOST` | PostgreSQL host | - |
| `POSTGRES_DB` | PostgreSQL database | - |
| `POSTGRES_USER` | PostgreSQL user | - |
| `POSTGRES_PASSWORD` | PostgreSQL password | - |

### Advanced Settings

| Variable | Description | Default |
|----------|-------------|---------|
| `ENABLE_SIGNUP` | Allow new user registration | `true` |
| `DEFAULT_USER_ROLE` | Default role for new users | `pending` |
| `ENABLE_COMMUNITY_SHARING` | Enable model sharing | `true` |
| `HF_HUB_OFFLINE` | Disable Hugging Face downloads | `false` |

## File Structure

```
open-webui/
├── backend/                 # Python FastAPI backend
│   ├── open_webui/         # Main application code
│   ├── requirements.txt    # Python dependencies
│   └── dev.sh             # Development startup script
├── src/                    # Svelte frontend source
│   ├── lib/               # Shared components and utilities
│   ├── routes/            # SvelteKit routes
│   └── app.html           # HTML template
├── static/                # Static assets
├── docker-compose.yaml    # Main compose file
├── package.json           # Node.js dependencies
├── vite.config.ts         # Vite configuration
└── svelte.config.js       # Svelte configuration
```

## Troubleshooting

### Connection Issues

**Problem**: "Server Connection Error"
**Solution**: 
```bash
# Use host networking
docker run -d --network=host \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```
Access at http://localhost:8080 (note port change)

### Development Issues

**Problem**: CORS errors in development
**Solution**: Ensure backend is started with correct CORS settings:
```bash
export CORS_ALLOW_ORIGIN=http://localhost:5173
```

**Problem**: Node.js version issues
**Solution**: Use Node.js version 18.13.0 - 22.x.x

### Database Issues

**Problem**: Database connection failed
**Solution**: Check database URL and ensure database server is running:
```bash
# For PostgreSQL example:
export DATABASE_URL="postgresql://user:password@localhost:5432/openwebui"
```

### GPU Issues

**Problem**: GPU not detected
**Solution**: 
1. Install NVIDIA Container Toolkit
2. Use GPU-enabled image: `ghcr.io/open-webui/open-webui:cuda`
3. Add `--gpus all` flag

## Updating

### Docker
```bash
# Pull latest image
docker pull ghcr.io/open-webui/open-webui:main

# Stop and remove current container
docker stop open-webui && docker rm open-webui

# Start with new image (use your original run command)

# Or use Watchtower for automatic updates
docker run --rm --volume /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --run-once open-webui
```

### Development
```bash
# Update dependencies
npm install
pip install -r backend/requirements.txt

# Pull latest changes
git pull origin main
```

## Production Deployment

### Docker Compose (Recommended)
```bash
# Create production compose file
cp docker-compose.yaml docker-compose.prod.yaml

# Add production environment variables
# Edit docker-compose.prod.yaml:
# - Set strong WEBUI_SECRET_KEY
# - Configure proper database
# - Set up reverse proxy
# - Enable SSL/TLS

# Deploy
docker compose -f docker-compose.prod.yaml up -d
```

### Security Checklist
- [ ] Set strong `WEBUI_SECRET_KEY`
- [ ] Use external database (PostgreSQL/MySQL)
- [ ] Set up reverse proxy (nginx/traefik)
- [ ] Enable SSL/TLS certificates
- [ ] Configure firewall rules
- [ ] Set up backup strategy
- [ ] Configure log rotation
- [ ] Disable development features

## Next Steps

1. **First Run**: Create admin account at http://localhost:3000
2. **Model Setup**: Configure your AI models (Ollama/OpenAI)
3. **User Management**: Set up user roles and permissions
4. **Customization**: Explore themes and UI customization
5. **Integration**: Connect external tools and APIs
6. **Backup**: Set up regular data backups

## Support

- **Documentation**: https://docs.openwebui.com/
- **Discord**: https://discord.gg/5rJgQTnV4s
- **GitHub Issues**: https://github.com/open-webui/open-webui/issues

## Useful Commands

```bash
# View logs
docker logs open-webui -f

# Access container shell
docker exec -it open-webui bash

# Backup data
docker run --rm -v open-webui:/data -v $(pwd):/backup \
  alpine tar czf /backup/open-webui-backup.tar.gz -C /data .

# Restore data
docker run --rm -v open-webui:/data -v $(pwd):/backup \
  alpine tar xzf /backup/open-webui-backup.tar.gz -C /data

# Check system status
docker stats open-webui
```

Happy coding! 🎉 