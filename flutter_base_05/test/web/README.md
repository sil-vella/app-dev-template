# Web Testing System

This directory contains the modular web testing system for the Flutter app using Puppeteer.

## 🚀 Quick Start

Run all tests:
```bash
cd flutter_base_05/test/web
./run_web_test.sh
```

## 📁 File Structure

```
test/web/
├── run_web_test.sh          # Main test entry point
├── test_runner.dart          # Test execution engine
├── test_config.dart          # Test configuration
├── single_web_test.dart      # Basic app functionality test
├── recall_game_test.dart     # Recall game screen test
└── README.md                 # This file
```

## 🔧 How It Works

### 1. Main Entry Point (`run_web_test.sh`)
- Builds the Flutter web app (`flutter build web`)
- Starts a local HTTP server (`python3 -m http.server 3000`)
- Runs the test runner (`dart test_runner.dart`)
- Keeps the server running for debugging

### 2. Test Runner (`test_runner.dart`)
- **Single Browser Session**: Uses one Chrome instance for all tests
- **App State Persistence**: Browser stays open between tests
- **Sequential Execution**: Runs tests in order from `test_config.dart`
- **Comprehensive Reporting**: Detailed pass/fail status for each test
- **Error Handling**: Screenshots and error details for failed tests

### 3. Test Configuration (`test_config.dart`)
- Defines which tests to run in order
- Provides test descriptions for better reporting
- Easy to add new tests by updating the configuration

### 4. Individual Test Files
Each test file focuses on specific functionality:
- `single_web_test.dart` - Basic app functionality (responsiveness, auth flow, app state)
- `recall_game_test.dart` - Recall game screen (navigation, UI elements, interactions)
- Add more test files for different screens/features

## 🌐 URL Structure & Hash-Based Routing

### **Important: Hash-Based URLs**
Flutter web uses hash-based routing by default. All URLs must include the `#` prefix:

- ✅ **Correct**: `http://localhost:3000/#/recall/lobby`
- ❌ **Incorrect**: `http://localhost:3000/recall/lobby`

### **Why Hash-Based Routing?**
- **Server Compatibility**: Works with any static file server
- **No Server Configuration**: No need to configure server-side routing
- **SPA Behavior**: Single Page Application behavior
- **Browser History**: Maintains browser history and back/forward buttons

### **Available Routes**
From the Flutter app:
- `/` - Home screen
- `/#/account` - Account screen (requires authentication)
- `/#/websocket` - WebSocket test screen
- `/#/auth-test` - Auth test screen
- `/#/recall/lobby` - Recall game lobby screen

## 📝 Adding New Tests

### Step 1: Create Test File
Create a new Dart file (e.g., `auth_test.dart`):

```dart
import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

Future<void> main() async {
  // Your test implementation
}
```

### Step 2: Add to Configuration
Update `test_config.dart`:

```dart
static const List<String> testFiles = [
  'single_web_test.dart',
  'recall_game_test.dart',
  'auth_test.dart',  // Add your new test
];

static const Map<String, String> testDescriptions = {
  'single_web_test.dart': 'Basic app functionality',
  'recall_game_test.dart': 'Recall game screen',
  'auth_test.dart': 'Authentication flow',  // Add description
};
```

### Step 3: Run Tests
```bash
./run_web_test.sh
```

## 🎯 Test Structure

Each test file should follow this pattern:

```dart
Future<void> main() async {
  // 1. Launch browser
  var browser = await puppeteer.launch(headless: false);
  var page = await browser.newPage();
  
  try {
    // 2. Navigate to app (use hash-based URLs)
    await page.goto('http://localhost:3000/#/your-route');
    
    // 3. Wait for app ready
    await _waitForAppReady(page);
    
    // 4. Run specific tests
    await _testSpecificFunctionality(page);
    
    // 5. Take screenshots
    var screenshot = await page.screenshot();
    await File('test_screenshot.png').writeAsBytes(screenshot);
    
  } catch (e) {
    // 6. Error handling
    print('Test failed: $e');
    rethrow;
  } finally {
    await browser.close();
  }
}
```

## 🔐 Authentication Handling

### **Automatic Login Detection**
The test system automatically detects when routes redirect to authentication screens:

```dart
// Check if redirected to auth screen
if (currentUrl.contains('/account') || currentUrl.contains('/auth')) {
  await _performLogin(page);
  // Re-navigate to original route
}
```

### **Login Credentials**
Login credentials are configured in `test_config.env`:
- **Email**: `TEST_EMAIL=silvester.vella@gmail.com`
- **Password**: `TEST_PASSWORD=12345678`

You can modify these values in the `test_config.env` file without changing the code.

### **Login Flow**
1. **Detect Redirect**: Check if URL contains `/account` or `/auth`
2. **Find Input Fields**: Look for email/password inputs
3. **Enter Credentials**: Type email and password
4. **Submit**: Click login button
5. **Re-navigate**: Return to original route

## 📸 Screenshots

All tests automatically save screenshots with timestamps:
- `recall_game_navigation_*.png` - Navigation test results
- `recall_game_ui_*.png` - UI element detection
- `recall_game_interactions_*.png` - Interaction test results
- `login_page_*.png` - Login screen state
- `login_attempt_*.png` - Login attempt results
- Error screenshots for failed tests

## 🔍 Debugging

### **Keep Server Running**
The test script keeps the web server running after tests complete:
```bash
# Stop the server manually
kill $SERVER_PID
```

### **View Screenshots**
Check the `test/web/` directory for screenshots from each test:
```bash
ls -la *.png
```

### **Browser Debugging**
Tests run with `headless: false` so you can see the browser actions in real-time.

### **Single Browser Session**
- **One Chrome Window**: Only one browser instance for all tests
- **State Persistence**: App state maintained between tests
- **Faster Execution**: No browser startup/shutdown between tests

## 🎮 Current Tests

### 1. Basic App Functionality (`single_web_test.dart`)
- **App Responsiveness**: Check if app loads and has content
- **Authentication Flow**: Look for auth-related UI elements
- **App State**: Check for loading/error states
- **App Ready Hook**: Wait for app initialization

### 2. Recall Game Screen (`recall_game_test.dart`)
- **Navigation**: Navigate to `/#/recall/lobby`
- **Redirect Handling**: Handle auth redirects automatically
- **Login Flow**: Perform login if redirected to account screen
- **UI Elements**: Check for lobby-specific elements (create room, join room, etc.)
- **Interactions**: Test clickable elements and state changes

## 🚀 Future Tests

Add these test files as needed:
- `auth_test.dart` - Authentication flow testing
- `profile_test.dart` - User profile screen testing
- `settings_test.dart` - Settings screen testing
- `leaderboard_test.dart` - Leaderboard screen testing
- `game_modes_test.dart` - Different game modes testing
- `performance_test.dart` - Performance testing

## ⚡ Best Practices

### **1. Test Isolation**
- Each test focuses on specific functionality
- Use descriptive test names
- Keep tests modular and focused

### **2. Error Handling**
- Always wrap tests in try-catch blocks
- Take screenshots on errors
- Provide detailed error messages

### **3. Wait for App Ready**
- Always wait for the `app_ready` hook
- Check for app initialization indicators
- Handle timeouts gracefully

### **4. Hash-Based URLs**
- **Always use `#` prefix** for Flutter web routes
- Example: `http://localhost:3000/#/recall/lobby`
- Never use: `http://localhost:3000/recall/lobby`

### **5. Screenshots**
- Take screenshots at key points
- Use descriptive filenames with timestamps
- Save screenshots for debugging

### **6. Authentication**
- Handle auth redirects automatically
- Use consistent login credentials
- Re-navigate after successful login

## 🔧 Configuration

### **Environment Configuration (`test_config.env`)**
The test system uses environment variables for configuration:

```bash
# Login credentials
TEST_EMAIL=silvester.vella@gmail.com
TEST_PASSWORD=12345678

# Test URLs
TEST_BASE_URL=http://localhost:3000
TEST_RECALL_GAME_URL=http://localhost:3000/#/recall/lobby
TEST_ACCOUNT_URL=http://localhost:3000/#/account

# Timeouts (in seconds)
APP_READY_TIMEOUT=30
LOGIN_TIMEOUT=10
NAVIGATION_TIMEOUT=5

# Screenshot settings
SCREENSHOT_DIR=.
SCREENSHOT_PREFIX=test_
```

### **Test Order**
Tests run in the order defined in `test_config.dart`:
```dart
static const List<String> testFiles = [
  'single_web_test.dart',      // Run first
  'recall_game_test.dart',     // Run second
  // Add more tests here
];
```

### **Browser Settings**
Chrome launched with these settings:
- `headless: false` - Visible browser for debugging
- Custom arguments for stability and performance
- Remote debugging port enabled

### **Server Settings**
- **Port**: 3000
- **Host**: localhost
- **Server**: Python HTTP server
- **Auto-cleanup**: Kills existing processes on port 3000

## 📊 Test Reporting

### **Success Indicators**
- ✅ All tests pass
- 📸 Screenshots saved
- 🎯 UI elements detected
- 🔐 Authentication handled

### **Failure Indicators**
- ❌ Test failures
- 📸 Error screenshots saved
- ⚠️ Missing UI elements
- 🔄 Navigation issues

The test system provides comprehensive reporting with detailed pass/fail status for each test. 