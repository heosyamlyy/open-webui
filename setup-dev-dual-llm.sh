#!/bin/bash

# Open WebUI Development Setup Script
# Sets up both Local LLM (Ollama) and OpenAI API connections

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}${1}${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_header "🚀 Open WebUI Development Setup: Local LLM + OpenAI API"
echo

# Check prerequisites
print_status "Checking prerequisites..."

# Check Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    print_status "Node.js found: $NODE_VERSION"
else
    print_error "Node.js not found. Please install Node.js 18.13.0 - 22.x.x"
    exit 1
fi

# Check npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    print_status "npm found: v$NPM_VERSION"
else
    print_error "npm not found. Please install npm 6.0.0+"
    exit 1
fi

# Check Python
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version)
    print_status "Python found: $PYTHON_VERSION"
elif command_exists python; then
    PYTHON_VERSION=$(python --version)
    print_status "Python found: $PYTHON_VERSION"
else
    print_error "Python not found. Please install Python 3.11+"
    exit 1
fi

# Check Ollama
if command_exists ollama; then
    print_status "Ollama found"
    OLLAMA_INSTALLED=true
else
    print_warning "Ollama not found. Will provide installation instructions."
    OLLAMA_INSTALLED=false
fi

echo

# Get OpenAI API key if not provided
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${BLUE}Please enter your OpenAI API Key:${NC}"
    echo "Get one from: https://platform.openai.com/api-keys"
    read -s -p "OpenAI API Key: " OPENAI_API_KEY
    echo
    if [ -z "$OPENAI_API_KEY" ]; then
        print_error "OpenAI API Key is required"
        exit 1
    fi
fi

# Install Ollama if not found
if [ "$OLLAMA_INSTALLED" = false ]; then
    echo
    print_header "📦 Installing Ollama..."
    
    # Detect OS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Detected macOS. Please install Ollama manually:"
        echo "1. Visit https://ollama.ai/download"
        echo "2. Download and install Ollama for macOS"
        echo "3. Run this script again"
        exit 1
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        print_status "Installing Ollama for Linux..."
        curl -fsSL https://ollama.ai/install.sh | sh
    else
        print_error "Unsupported OS. Please install Ollama manually from https://ollama.ai/"
        exit 1
    fi
fi

# Check if Ollama is running
print_status "Checking if Ollama is running..."
if curl -s http://localhost:11434/api/tags >/dev/null 2>&1; then
    print_status "Ollama is running"
else
    print_warning "Ollama is not running. Starting Ollama..."
    if command_exists systemctl; then
        sudo systemctl start ollama
    else
        print_warning "Please start Ollama manually: ollama serve"
        echo "Press Enter when Ollama is running..."
        read
    fi
fi

# Install Node.js dependencies
print_header "📦 Installing Node.js dependencies..."
npm install

# Setup Python virtual environment
print_header "🐍 Setting up Python environment..."
cd backend

# Determine Python command
if command_exists python3; then
    PYTHON_CMD=python3
else
    PYTHON_CMD=python
fi

# Create virtual environment
if [ ! -d "venv" ]; then
    print_status "Creating Python virtual environment..."
    $PYTHON_CMD -m venv venv
fi

# Activate virtual environment and install dependencies
print_status "Installing Python dependencies..."
source venv/bin/activate
pip install -r requirements.txt

# Create .env.dev file
print_status "Creating development environment file..."
cat > .env.dev << EOF
# OpenAI Configuration
OPENAI_API_KEY=$OPENAI_API_KEY
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

# Optional: Uncomment to add multiple providers
# OPENAI_API_BASE_URLS=https://api.openai.com/v1;https://api.openrouter.ai/api/v1
# OPENAI_API_KEYS=$OPENAI_API_KEY;sk-your-other-key
# OLLAMA_BASE_URLS=http://localhost:11434;http://another-server:11434
EOF

print_status "Environment file created: backend/.env.dev"

# Download some models for development
print_header "🤖 Downloading development models..."
cd ..

MODELS_TO_DOWNLOAD=(
    "llama3.2:1b"
    "phi3:mini"
)

for model in "${MODELS_TO_DOWNLOAD[@]}"; do
    print_status "Downloading $model..."
    if ollama pull "$model"; then
        print_status "✓ Downloaded $model"
    else
        print_warning "Failed to download $model (you can download it later)"
    fi
done

# Create start scripts
print_header "📝 Creating startup scripts..."

# Backend start script
cat > start-backend-dev.sh << 'EOF'
#!/bin/bash
cd backend
source venv/bin/activate
export $(cat .env.dev | xargs)
./dev.sh
EOF

chmod +x start-backend-dev.sh

# Frontend start script  
cat > start-frontend-dev.sh << 'EOF'
#!/bin/bash
npm run dev
EOF

chmod +x start-frontend-dev.sh

# Comprehensive start script
cat > start-dev-servers.sh << 'EOF'
#!/bin/bash

# Function to cleanup background processes
cleanup() {
    echo "Shutting down development servers..."
    kill $(jobs -p) 2>/dev/null
    exit 0
}

# Trap Ctrl+C
trap cleanup SIGINT

echo "🚀 Starting Open WebUI Development Servers..."
echo "Backend: http://localhost:8080"
echo "Frontend: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Start backend
echo "Starting backend..."
./start-backend-dev.sh &

# Wait a moment for backend to start
sleep 3

# Start frontend
echo "Starting frontend..."
./start-frontend-dev.sh &

# Wait for both processes
wait
EOF

chmod +x start-dev-servers.sh

# Test connections
print_header "🔍 Testing connections..."

# Test Ollama
if curl -s http://localhost:11434/api/tags >/dev/null; then
    print_status "✓ Ollama connection successful"
else
    print_warning "✗ Ollama connection failed"
fi

# Test OpenAI
if curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models >/dev/null; then
    print_status "✓ OpenAI API connection successful"
else
    print_warning "✗ OpenAI API connection failed (check your API key)"
fi

# Final instructions
print_header "✅ Setup Complete!"
echo
print_status "Your development environment is ready!"
echo
echo -e "${BLUE}Next steps:${NC}"
echo "1. Start development servers:"
echo "   ${GREEN}./start-dev-servers.sh${NC}"
echo
echo "2. Or start them separately:"
echo "   Terminal 1: ${GREEN}./start-backend-dev.sh${NC}"
echo "   Terminal 2: ${GREEN}./start-frontend-dev.sh${NC}"
echo
echo "3. Open your browser:"
echo "   Frontend: ${GREEN}http://localhost:5173${NC}"
echo "   Backend API: ${GREEN}http://localhost:8080${NC}"
echo
echo "4. Create an account (first user becomes admin)"
echo "5. Check Admin Panel → Settings → Connections"
echo
print_status "Available Ollama models:"
ollama list 2>/dev/null || echo "  Run 'ollama list' to see models"
echo
print_status "Happy developing! 🎉" 