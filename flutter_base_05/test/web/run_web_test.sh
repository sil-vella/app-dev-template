#!/bin/bash

echo "🚀 Starting web test with Puppeteer Chrome only..."
echo "📝 Note: This will open ONE Chrome window (Puppeteer's) that runs the Flutter app"
echo ""

# Navigate to Flutter project root
cd ../../

# Build the Flutter web app first
echo "🔨 Building Flutter web app..."
flutter build web --web-renderer=html --dart-define=FLUTTER_WEB_USE_SKIA=false

# Kill any existing process on port 3000
echo "🧹 Checking for existing processes on port 3000..."
lsof -ti:3000 | xargs kill -9 2>/dev/null || true

# Serve the built app locally
echo "🌐 Serving Flutter web app on localhost:3000..."
cd build/web
python3 -m http.server 3000 &
SERVER_PID=$!

echo "📱 Web server starting with PID: $SERVER_PID"

# Wait for the server to be ready
echo "⏳ Waiting for web server to be ready on localhost:3000..."

# Function to check if server is ready
check_server_ready() {
  if curl -s http://localhost:3000 > /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Wait up to 30 seconds for the server to be ready
COUNTER=0
while [ $COUNTER -lt 30 ]; do
  if check_server_ready; then
    echo "✅ Web server is ready on localhost:3000"
    break
  fi
  echo "⏳ Waiting for server... ($COUNTER/30)"
  sleep 1
  COUNTER=$((COUNTER + 1))
done

if [ $COUNTER -eq 30 ]; then
  echo "❌ Web server failed to start within 30 seconds"
  kill $SERVER_PID 2>/dev/null
  exit 1
fi

# Give the server a moment to fully initialize
echo "⏳ Giving server 3 seconds to fully initialize..."
sleep 3

# Run the web tests using the test runner
echo "🧪 Running web tests using test runner..."
echo "🔍 Puppeteer will open Chrome and test the Flutter web app..."

# Navigate to test directory and run all tests using the test runner
echo "🚀 Starting test runner..."
cd ../../test/web
dart test_runner.dart
TEST_EXIT_CODE=$?

echo "🏁 Test completed with exit code: $TEST_EXIT_CODE"

# Keep the web server running for debugging
echo "🔧 Keeping web server running for debugging..."
echo "📱 Web server is still running with PID: $SERVER_PID"
echo "🌐 App is available at: http://localhost:3000"
echo "🛑 To stop the server, run: kill $SERVER_PID"
echo ""
echo "🧪 Tests completed with exit code: $TEST_EXIT_CODE"
echo "📸 Screenshots saved in: test/web/"
echo ""
echo "💡 Single Chrome Window:"
echo "   - Puppeteer opens Chrome with correct arguments"
echo "   - Chrome loads the Flutter web app from localhost:3000"
echo "   - Only one Chrome window is used"
echo ""
echo "🔧 Modular Testing System:"
echo "   - Test runner executes multiple test files"
echo "   - Each test file focuses on specific functionality"
echo "   - Easy to add new test files in test_config.dart"
echo "   - All tests run sequentially in the same browser session"
echo "   - Comprehensive test reporting and error handling"

# Exit with the test exit code
exit $TEST_EXIT_CODE 