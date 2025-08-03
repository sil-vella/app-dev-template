#!/bin/bash

# Direct Puppeteer Test Runner
# This script runs Puppeteer directly without Dart tests

set -e

echo "🚀 Starting Direct Puppeteer Test"
echo "=================================="

# Change to the test directory
cd "$(dirname "$0")"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js first."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm first."
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "node_modules" ]; then
    echo "📦 Installing Node.js dependencies..."
    npm install
fi

# Check if the Flutter app is running on port 3000
if ! curl -s http://localhost:3000 > /dev/null; then
    echo "⚠️  Flutter app is not running on localhost:3000"
    echo "💡 Please start the Flutter app first:"
    echo "   cd ../../ && ./test/web/run_web_test.sh"
    echo ""
    echo "Or manually:"
    echo "   flutter build web"
    echo "   cd build/web && python3 -m http.server 3000"
    echo ""
    read -p "Press Enter to continue anyway, or Ctrl+C to cancel..."
fi

# Run the direct Puppeteer test
echo "🧪 Running direct Puppeteer test..."
node puppeteer_direct_test.js

echo ""
echo "✅ Direct Puppeteer test completed!"
echo "📸 Check the screenshots in this directory:"
echo "   - test_screenshot_initial.png"
echo "   - test_screenshot_recall_game.png"
echo "   - test_screenshot_final.png"
echo "   - test_screenshot_error.png (if any errors occurred)" 