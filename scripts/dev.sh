#!/bin/bash
# TrossApp Development Startup Script
# Handles clean startup and common development tasks

echo "🚀 TrossApp Development Environment Setup"
echo "=========================================="

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Function to check if a service is running on a port
check_port() {
    if netstat -ano | grep ":$1" > /dev/null; then
        echo "✅ Service already running on port $1"
        return 0
    else
        return 1
    fi
}

# Function to start backend
start_backend() {
    echo "🔧 Starting backend server..."
    cd backend
    
    # Check if backend is already running
    if check_port 3001; then
        echo "Backend already running"
    else
        echo "Starting Node.js backend..."
        npm start &
        sleep 3
        if check_port 3001; then
            echo "✅ Backend started successfully on port 3001"
        else
            echo "❌ Backend failed to start"
            exit 1
        fi
    fi
    cd ..
}

# Function to start frontend with clean build
start_frontend() {
    echo "📱 Starting Flutter frontend..."
    cd frontend
    
    # Clean previous builds
    echo "🧹 Cleaning Flutter build cache..."
    flutter clean
    rm -rf build/ 2>/dev/null || true
    
    # Get dependencies
    echo "📦 Getting Flutter dependencies..."
    flutter pub get
    
    # Start Flutter
    echo "🚀 Starting Flutter app..."
    flutter run --web-browser-flag "--disable-web-security"
    
    cd ..
}

# Function to show development URLs
show_urls() {
    echo ""
    echo "📍 Development URLs:"
    echo "   Backend API: http://localhost:3001/api/health"
    echo "   Dev Status:  http://localhost:3001/api/dev/status"
    echo "   Flutter App: (will open automatically in browser)"
    echo ""
}

# Main menu
case "${1:-start}" in
    "start")
        echo "Starting full development environment..."
        start_backend
        show_urls
        echo "Backend running. Press any key to start Flutter..."
        read -n 1
        start_frontend
        ;;
    "backend")
        start_backend
        show_urls
        echo "Backend only mode. Frontend can be started separately."
        ;;
    "frontend")
        start_frontend
        ;;
    "clean")
        echo "🧹 Cleaning development environment..."
        cd frontend
        flutter clean
        rm -rf build/ 2>/dev/null || true
        cd ../backend
        rm -rf node_modules/.cache 2>/dev/null || true
        echo "✅ Cleanup complete"
        ;;
    "help")
        echo "Usage: $0 [command]"
        echo "Commands:"
        echo "  start    - Start both backend and frontend (default)"
        echo "  backend  - Start only backend"
        echo "  frontend - Start only frontend" 
        echo "  clean    - Clean build caches"
        echo "  help     - Show this help"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use '$0 help' for available commands"
        exit 1
        ;;
esac