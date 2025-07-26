# Development Setup Guide: Local LLM + OpenAI API 🔧

A step-by-step guide to set up Open WebUI development environment with both **local LLM (Ollama)** and **OpenAI API** connections simultaneously.

## Overview

This guide will help you create a development environment where you can:
- ✅ Connect to local Ollama models
- ✅ Connect to OpenAI API
- ✅ Switch between providers seamlessly
- ✅ Test both connections in real-time
- ✅ Develop and debug with hot reload

## Prerequisites

- **Node.js**: 18.13.0 - 22.x.x
- **npm**: 6.0.0+
- **Python**: 3.11+
- **Git**
- **OpenAI API Key** (get from [OpenAI Platform](https://platform.openai.com/api-keys))
- **Ollama** installed locally (get from [ollama.ai](https://ollama.ai/))

## Quick Setup (5 minutes)

### Step 1: Install Ollama & Pull Models

```bash
# Install Ollama (if not already installed)
curl -fsSL https://ollama.ai/install.sh | sh

# Start Ollama service
ollama serve

# In a new terminal, pull some models
ollama pull llama3.2:1b    # Small, fast model for development
ollama pull codellama:7b   # Good for code assistance
ollama pull phi3:mini      # Another small option

# Verify Ollama is running
curl http://localhost:11434/api/tags
```

### Step 2: Setup Development Environment

```bash
# Clone and navigate to the project
git clone <your-repo-url>
cd open-webui

# Install frontend dependencies
npm install

# Setup backend
cd backend
python -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Install backend dependencies
pip install -r requirements.txt
```

### Step 3: Create Development Environment File

Create a `.env.dev` file in the `backend/` directory:

```bash
# backend/.env.dev

# OpenAI Configuration
OPENAI_API_KEY=sk-your-openai-api-key-here
OPENAI_API_BASE_URL=https://api.openai.com/v1
ENABLE_OPENAI_API=True

# Ollama Configuration  
OLLAMA_BASE_URL=http://localhost:11434
ENABLE_OLLAMA_API=True

# Development settings
CORS_ALLOW_ORIGIN=http://localhost:5173
ENV=dev
PORT=8080

# Enable both providers simultaneously
ENABLE_DIRECT_CONNECTIONS=True

# Optional: Add multiple providers (semicolon-separated)
# OPENAI_API_BASE_URLS=https://api.openai.com/v1;https://api.openrouter.ai/api/v1
# OPENAI_API_KEYS=sk-openai-key;sk-openrouter-key
# OLLAMA_BASE_URLS=http://localhost:11434;http://another-ollama:11434
```

### Step 4: Start Development Servers

**Terminal 1 - Backend:**
```bash
cd backend
source venv/bin/activate  # Activate venv if not already active

# Load environment variables and start backend
export $(cat .env.dev | xargs) && ./dev.sh

# Or manually:
# export $(cat .env.dev | xargs)
# uvicorn open_webui.main:app --port 8080 --host 0.0.0.0 --reload
```

**Terminal 2 - Frontend:**
```bash
# From project root
npm run dev

# Backend will be at: http://localhost:8080
# Frontend will be at: http://localhost:5173
```

## Verification & Testing

### Test Ollama Connection

```bash
# Test Ollama API directly
curl http://localhost:11434/api/tags

# Test through Open WebUI backend
curl http://localhost:8080/ollama/api/tags \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Test OpenAI Connection

```bash
# Test OpenAI API directly
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer sk-your-api-key"

# Test through Open WebUI backend
curl http://localhost:8080/openai/v1/models \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Web Interface Testing

1. **Open**: http://localhost:5173
2. **Create Account**: Sign up as the first user (you'll be admin)
3. **Check Connections**: Go to **Admin Panel** → **Settings** → **Connections**
4. **Verify Models**: You should see both Ollama and OpenAI models available

## Configuration Details

### Environment Variables Reference

| Variable | Purpose | Example |
|----------|---------|---------|
| `OPENAI_API_KEY` | Single OpenAI API key | `sk-proj-xxx...` |
| `OPENAI_API_KEYS` | Multiple API keys (`;` separated) | `sk-key1;sk-key2` |
| `OPENAI_API_BASE_URL` | Single OpenAI endpoint | `https://api.openai.com/v1` |
| `OPENAI_API_BASE_URLS` | Multiple endpoints (`;` separated) | `https://api.openai.com/v1;https://api.openrouter.ai/api/v1` |
| `OLLAMA_BASE_URL` | Single Ollama instance | `http://localhost:11434` |
| `OLLAMA_BASE_URLS` | Multiple Ollama instances (`;` separated) | `http://localhost:11434;http://server2:11434` |
| `ENABLE_OPENAI_API` | Enable/disable OpenAI | `True` / `False` |
| `ENABLE_OLLAMA_API` | Enable/disable Ollama | `True` / `False` |

### Advanced Multi-Provider Setup

For multiple providers of the same type:

```bash
# Multiple OpenAI-compatible providers
OPENAI_API_BASE_URLS=https://api.openai.com/v1;https://api.anthropic.com/v1;https://api.openrouter.ai/api/v1
OPENAI_API_KEYS=sk-openai-key;sk-anthropic-key;sk-openrouter-key

# Multiple Ollama instances
OLLAMA_BASE_URLS=http://localhost:11434;http://gpu-server:11434;http://remote-ollama:11434
```

## Development Workflow

### Hot Reload Development

1. **Backend Changes**: 
   - Modify Python files in `backend/open_webui/`
   - Backend auto-reloads thanks to `--reload` flag

2. **Frontend Changes**:
   - Modify Svelte files in `src/`
   - Vite provides instant hot module replacement

3. **Configuration Changes**:
   - Update `.env.dev` file
   - Restart backend server to pick up new environment variables

### Testing Different Models

```bash
# Add more Ollama models for testing
ollama pull mistral:7b
ollama pull gemma2:2b
ollama pull qwen2:1.5b

# List available models
ollama list
```

### Debugging Tips

1. **Check Backend Logs**:
   ```bash
   # Backend terminal shows detailed logs
   # Look for connection status on startup
   ```

2. **Check Frontend Network Tab**:
   - Open browser DevTools → Network
   - Monitor API calls to `/ollama/` and `/openai/` endpoints

3. **Verify Model Loading**:
   ```bash
   # Check loaded models via API
   curl http://localhost:8080/api/models
   ```

## Common Development Issues

### Issue: "Connection refused" to Ollama

**Solution:**
```bash
# Make sure Ollama is running
ollama serve

# Check if accessible
curl http://localhost:11434/api/tags

# Verify environment variable
echo $OLLAMA_BASE_URL
```

### Issue: "Invalid API key" for OpenAI

**Solution:**
```bash
# Verify API key is set correctly
echo $OPENAI_API_KEY

# Test API key directly
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY"
```

### Issue: CORS errors in browser

**Solution:**
```bash
# Ensure CORS is set for frontend URL
export CORS_ALLOW_ORIGIN=http://localhost:5173

# Restart backend after setting
```

### Issue: Models not appearing in UI

**Solutions:**
1. **Check Admin Settings**: Go to Admin Panel → Settings → Connections
2. **Verify API Endpoints**: Both Ollama and OpenAI should be enabled
3. **Restart Services**: Sometimes a restart helps refresh model lists
4. **Check Logs**: Look for error messages in backend terminal

## Advanced Development Features

### Custom Model Configurations

You can configure specific settings per provider in the web interface:

1. **Admin Panel** → **Settings** → **Connections**
2. Click on individual Ollama/OpenAI connections
3. Configure timeouts, custom headers, etc.

### Multiple API Keys Rotation

```bash
# For load balancing or rate limit management
OPENAI_API_KEYS=sk-key1;sk-key2;sk-key3
```

### Development with Remote Ollama

```bash
# Connect to Ollama on different server
OLLAMA_BASE_URL=http://192.168.1.100:11434

# Or multiple remote instances
OLLAMA_BASE_URLS=http://server1:11434;http://server2:11434
```

## Testing Scenarios

### Test Chat Completions

1. **Ollama Model**: Start chat with a local model (e.g., llama3.2)
2. **OpenAI Model**: Switch to GPT-4 or GPT-3.5-turbo
3. **Compare Responses**: Test same prompt on both providers

### Test Function Calling

```bash
# Some models support function calling
# Test with both local and OpenAI models that support tools
```

### Test Image Generation

```bash
# If using DALL-E or local Stable Diffusion
# Configure image generation endpoints
```

## Production Preparation

When ready to deploy, consider:

1. **Environment Variables**: Move from `.env.dev` to proper deployment configs
2. **API Key Security**: Use secrets management (not plain text files)
3. **Rate Limiting**: Configure appropriate limits for each provider
4. **Monitoring**: Set up logging and monitoring for both providers
5. **Backup Configuration**: Document your working configuration

## Useful Development Commands

```bash
# Check what models are available
curl http://localhost:8080/api/models | jq

# Monitor backend logs with specific filters
tail -f backend.log | grep -E "(ollama|openai)"

# Test specific model endpoint
curl http://localhost:8080/ollama/api/chat \
  -d '{"model": "llama3.2", "messages": [{"role": "user", "content": "Hello"}]}'

# Check frontend build
npm run build && npm run preview

# Run type checking
npm run check

# Format code
npm run format
```

## Next Steps

1. **Experiment**: Try different models and compare responses
2. **Customize**: Modify prompts, temperature settings, etc.
3. **Extend**: Add more providers or custom endpoints
4. **Optimize**: Profile performance with different models
5. **Deploy**: Move to production with your optimized configuration

## Support & Resources

- **Open WebUI Docs**: https://docs.openwebui.com/
- **Ollama Models**: https://ollama.ai/library
- **OpenAI API Docs**: https://platform.openai.com/docs
- **Discord Community**: https://discord.gg/5rJgQTnV4s

Happy developing! 🚀 