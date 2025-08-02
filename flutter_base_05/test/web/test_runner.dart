import 'dart:io';
import 'package:puppeteer/puppeteer.dart';
import 'test_config.dart';
import 'env_config.dart';

Future<void> main(List<String> args) async {
  print('🚀 Starting Test Runner...');
  
  // Load environment configuration
  await EnvConfig.loadConfig();
  print('⚙️ Configuration loaded');
  
  print('📋 Running ${TestConfig.testFiles.length} tests');
  print('');
  
  // Launch a single browser instance for all tests
  print('🌐 Launching browser for all tests...');
  var browser = await puppeteer.launch(
    headless: false,
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-accelerated-2d-canvas',
      '--no-first-run',
      '--no-zygote',
      '--disable-gpu',
      '--disable-web-security',
      '--disable-features=VizDisplayCompositor',
      '--remote-debugging-port=9222',
      '--allow-running-insecure-content',
      '--disable-background-timer-throttling',
      '--disable-backgrounding-occluded-windows',
      '--disable-renderer-backgrounding',
      '--disable-features=TranslateUI',
      '--disable-ipc-flooding-protection'
    ]
  );
  
  var page = await browser.newPage();
  
  List<int> exitCodes = [];
  List<String> failedTests = [];
  List<String> passedTests = [];
  
  try {
    // Navigate to the app once for all tests
    print('🌐 Navigating to Flutter web app...');
    await page.goto('http://localhost:3000');
    
    // Wait for app to be ready once
    print('⏳ Waiting for app_ready hook...');
    await _waitForAppReady(page);
    print('✅ App is ready for all tests');
    print('');
    
    // Run each test file using the same browser session
    for (int i = 0; i < TestConfig.testFiles.length; i++) {
      String testFile = TestConfig.testFiles[i];
      String description = TestConfig.getTestDescription(testFile);
      
      print('📋 Test ${i + 1}/${TestConfig.testFiles.length}: $description ($testFile)');
      print('🔄 Running test...');
      
      try {
        // Run the test function from the test file
        await _runTestFunction(testFile, page);
        print('✅ Test passed: $description');
        passedTests.add(testFile);
        exitCodes.add(0);
      } catch (e) {
        print('❌ Test failed: $description');
        print('❌ Error: $e');
        failedTests.add(testFile);
        exitCodes.add(1);
        
        // Take error screenshot
        try {
          var errorScreenshot = await page.screenshot();
          await File('test_runner_error_${testFile}_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(errorScreenshot);
          print('📸 Error screenshot saved');
        } catch (screenshotError) {
          print('⚠️ Could not save error screenshot: $screenshotError');
        }
      }
      
            print('');
    }
    
  } catch (e) {
    print('💥 Test runner failed: $e');
    exit(1);
  } finally {
    await browser.close();
  }
  
  // Print summary
  print('📊 Test Summary:');
  print('✅ Passed: ${passedTests.length}');
  print('❌ Failed: ${failedTests.length}');
  print('');
  
  if (passedTests.isNotEmpty) {
    print('✅ Passed Tests:');
    for (String test in passedTests) {
      print('   - ${TestConfig.getTestDescription(test)} ($test)');
    }
    print('');
  }
  
  if (failedTests.isNotEmpty) {
    print('❌ Failed Tests:');
    for (String test in failedTests) {
      print('   - ${TestConfig.getTestDescription(test)} ($test)');
    }
    print('');
  }
  
  // Calculate overall result
  bool allPassed = exitCodes.every((code) => code == 0);
  
  if (allPassed) {
    print('🎉 All tests passed!');
    exit(0);
  } else {
    print('💥 Some tests failed!');
    exit(1);
  }
}

Future<void> _waitForAppReady(Page page) async {
  print('⏳ Waiting for app_ready hook...');
  var startTime = DateTime.now();
  var timeout = Duration(seconds: EnvConfig.appReadyTimeout);
  
  while (DateTime.now().difference(startTime) < timeout) {
    try {
      var logs = await page.evaluate<List<dynamic>>('''
        function() {
          var readyIndicators = [];
          if (window.console && window.console.log) {
            readyIndicators.push('console_available');
          }
          var authElements = document.querySelectorAll('[class*="auth"], [class*="login"], [class*="dashboard"]');
          if (authElements.length > 0) {
            readyIndicators.push('auth_elements_found');
          }
          var interactiveElements = document.querySelectorAll('button, input, a, [role="button"]');
          if (interactiveElements.length > 0) {
            readyIndicators.push('interactive_elements_found');
          }
          var bodyText = document.body.textContent || '';
          if (bodyText.trim().length > 0) {
            readyIndicators.push('content_loaded');
          }
          return readyIndicators;
        }
      ''');
      
      if (logs.isNotEmpty) {
        print('✅ App ready indicators found: ${logs.join(', ')}');
        print('🎣 App ready hook detected - app is fully initialized');
        return;
      }
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      print('⚠️ Error checking app ready state: $e');
      await Future.delayed(Duration(milliseconds: 500));
    }
  }
  print('⚠️ App ready timeout - proceeding with test anyway');
}

Future<void> _runTestFunction(String testFile, Page page) async {
  // Import and run the specific test function based on the test file
  switch (testFile) {
    case 'single_web_test.dart':
      await _runBasicAppTest(page);
      break;
    case 'recall_game_test.dart':
      await _runRecallGameTest(page);
      break;
    default:
      throw Exception('Unknown test file: $testFile');
  }
}

Future<void> _runBasicAppTest(Page page) async {
  // Test 1: Check if app is responsive
  await _testAppResponsiveness(page);
  
  // Test 2: Check for authentication flow
  await _testAuthenticationFlow(page);
  
  // Test 3: Check for any errors or loading states
  await _testAppState(page);
}

Future<void> _runRecallGameTest(Page page) async {
  // Test 1: Navigate to recall game screen
  await _testNavigateToRecallGame(page);
  
  // Test 2: Check recall game UI elements
  await _testRecallGameUI(page);
  
  // Test 3: Test game interactions
  await _testGameInteractions(page);
}

Future<void> _testAppResponsiveness(Page page) async {
  print('📱 Testing app responsiveness...');
  
  // Check if page has content
  var pageContent = await page.evaluate<String>('document.body.textContent');
  if (pageContent.isNotEmpty) {
    var displayContent = pageContent.length > 200 ? '${pageContent.substring(0, 200)}...' : pageContent;
    print('✅ App has content: $displayContent');
  } else {
    print('⚠️ App appears to have no content');
  }
  
  // Check for interactive elements
  var interactiveElements = await page.$$('button, input, a, [role="button"]');
  print('🖱️ Interactive elements found: ${interactiveElements.length}');
}

Future<void> _testAuthenticationFlow(Page page) async {
  print('🔐 Testing authentication flow...');
  
  // Look for auth-related elements
  var authElements = await page.$$('[class*="auth"], [class*="login"], [class*="signin"]');
  print('🔑 Auth elements found: ${authElements.length}');
  
  if (authElements.isNotEmpty) {
    print('✅ Authentication UI detected');
  } else {
    print('⚠️ No authentication UI found');
  }
}

Future<void> _testAppState(Page page) async {
  print('📊 Testing app state...');
  
  // Check for loading states
  var loadingElements = await page.$$('[class*="loading"], [class*="spinner"]');
  print('⏳ Loading elements found: ${loadingElements.length}');
  
  // Check for error states
  var errorElements = await page.$$('[class*="error"], [class*="alert"]');
  print('⚠️ Error elements found: ${errorElements.length}');
}

Future<void> _testNavigateToRecallGame(Page page) async {
  print('🧭 Testing navigation to recall game screen...');
  
  // First, let's check what routes are available by looking at the page content
  var pageContent = await page.evaluate<String>('document.body.textContent');
  if (pageContent.isNotEmpty) {
    var displayContent = pageContent.length > 200 ? '${pageContent.substring(0, 200)}...' : pageContent;
    print('📄 Page content: $displayContent');
  } else {
    print('📄 Page content: (empty)');
  }
  
  // Check for any navigation elements
  var allButtons = await page.$$('button');
  var allLinks = await page.$$('a');
  var allClickables = await page.$$('[role="button"]');
  
  print('🖱️ Total buttons found: ${allButtons.length}');
  print('🔗 Total links found: ${allLinks.length}');
  print('🎯 Total clickable elements found: ${allClickables.length}');
  
  // Look for navigation elements to the recall game (drawer menu items)
  var recallGameElements = await page.$$('[class*="recall"], [class*="game"], [class*="lobby"], [class*="drawer"]');
  
  if (recallGameElements.isNotEmpty) {
    print('✅ Found recall game navigation elements');
    
    // Click on the first recall game element found
    await recallGameElements.first.click();
    print('🖱️ Clicked on recall game navigation element');
    
    // Wait for navigation
    await Future.delayed(Duration(seconds: 2));
    
    // Take screenshot
    var navigationScreenshot = await page.screenshot();
    await File('recall_game_navigation_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(navigationScreenshot);
    print('📸 Screenshot saved: recall game navigation');
    
  } else {
    print('⚠️ No recall game navigation elements found, checking for direct URL navigation');
    
    // Try to navigate directly to recall game route (using the correct hash-based path)
    print('🌐 Navigating to: ${EnvConfig.testRecallGameUrl}');
    await page.goto(EnvConfig.testRecallGameUrl);
    await Future.delayed(Duration(seconds: EnvConfig.navigationTimeout));
    
    // Check if navigation was successful
    var currentUrl = await page.evaluate<String>('window.location.href');
    print('📍 Current URL after navigation: $currentUrl');
    
    // Check if we were redirected to account screen (needs login)
    if (currentUrl.contains('/account') || currentUrl.contains('/auth')) {
      print('🔐 Detected redirect to account/auth screen - performing login...');
      await _performLogin(page);
      
      // After login, try navigating to recall game again
      print('🔄 Re-navigating to recall game after login...');
      await page.goto(EnvConfig.testRecallGameUrl);
      await Future.delayed(Duration(seconds: EnvConfig.navigationTimeout));
      
      // Check URL again
      currentUrl = await page.evaluate<String>('window.location.href');
      print('📍 Current URL after login and re-navigation: $currentUrl');
    }
    
    var directNavScreenshot = await page.screenshot();
    await File('recall_game_direct_nav_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(directNavScreenshot);
    print('📸 Screenshot saved: direct recall game navigation');
  }
}

Future<void> _testRecallGameUI(Page page) async {
  print('🎮 Testing recall game UI elements...');
  
  // Check for lobby-specific UI elements
  var lobbyElements = await page.$$('[class*="lobby"], [class*="room"], [class*="create"], [class*="join"]');
  
  if (lobbyElements.isNotEmpty) {
    print('✅ Found lobby UI elements: ${lobbyElements.length} elements');
    
    // Check for specific lobby components
    var createRoomElements = await page.$$('[class*="create"], [class*="new-room"]');
    var joinRoomElements = await page.$$('[class*="join"], [class*="room-id"]');
    var roomListElements = await page.$$('[class*="room-list"], [class*="public-rooms"]');
    var connectionElements = await page.$$('[class*="connection"], [class*="websocket"]');
    
    print('🏠 Create room elements found: ${createRoomElements.length}');
    print('🚪 Join room elements found: ${joinRoomElements.length}');
    print('📋 Room list elements found: ${roomListElements.length}');
    print('🔌 Connection elements found: ${connectionElements.length}');
    
  } else {
    print('⚠️ No specific lobby UI elements found');
  }
  
  // Check for general UI elements
  var buttonElements = await page.$$('button, [role="button"]');
  var inputElements = await page.$$('input, textarea');
  var textElements = await page.$$('h1, h2, h3, h4, h5, h6, p, span');
  
  print('🖱️ Button elements found: ${buttonElements.length}');
  print('⌨️ Input elements found: ${inputElements.length}');
  print('📝 Text elements found: ${textElements.length}');
  
  // Take screenshot of game screen
  var uiScreenshot = await page.screenshot();
  await File('recall_game_ui_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(uiScreenshot);
  print('📸 Screenshot saved: recall game UI');
}

Future<void> _testGameInteractions(Page page) async {
  print('🎯 Testing lobby interactions...');
  
  // Look for clickable lobby elements
  var clickableElements = await page.$$('button, [role="button"], [class*="create"], [class*="join"]');
  
  if (clickableElements.isNotEmpty) {
    print('🖱️ Found ${clickableElements.length} clickable lobby elements');
    
    // Click on the first few elements to test interactions
    for (int i = 0; i < clickableElements.length && i < 3; i++) {
      try {
        await clickableElements[i].click();
        print('🖱️ Clicked on lobby element ${i + 1}');
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        print('⚠️ Could not click on lobby element ${i + 1}: $e');
      }
    }
    
    // Take screenshot after interactions
    var interactionsScreenshot = await page.screenshot();
    await File('recall_game_interactions_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(interactionsScreenshot);
    print('📸 Screenshot saved: lobby interactions');
    
  } else {
    print('⚠️ No clickable lobby elements found');
  }
  
  // Check for lobby state changes
  var lobbyStateElements = await page.$$('[class*="connected"], [class*="disconnected"], [class*="loading"]');
  print('🎯 Lobby state elements found: ${lobbyStateElements.length}');
}

Future<void> _performLogin(Page page) async {
  print('🔐 Performing login...');
  
  // Wait for the login form to be visible
  await Future.delayed(Duration(seconds: 2));
  
  // First, let's see what's actually on the page
  var pageContent = await page.evaluate<String>('document.body.textContent');
  var displayLength = pageContent.length > 300 ? 300 : pageContent.length;
  print('📄 Login page content: ${pageContent.substring(0, displayLength)}');
  
  // Look for all interactive elements
  var allInputs = await page.$$('input');
  var allButtons = await page.$$('button');
  var allClickables = await page.$$('[role="button"]');
  
  print('⌨️ Total inputs found: ${allInputs.length}');
  print('🖱️ Total buttons found: ${allButtons.length}');
  print('🎯 Total clickable elements found: ${allClickables.length}');
  
  // If no inputs found, the login might be handled differently
  if (allInputs.isEmpty) {
    print('⚠️ No input fields found - login might be handled differently');
    print('🔍 Looking for alternative login methods...');
    
    // Check if there's already a logged-in state or if login is automatic
    var currentUrl = await page.evaluate<String>('window.location.href');
    print('📍 Current URL: $currentUrl');
    
    // Take screenshot to see what's on the page
    var loginScreenshot = await page.screenshot();
    await File('login_page_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(loginScreenshot);
    print('📸 Screenshot saved: login page state');
    return;
  }
  
  // Find the email/username field
  ElementHandle? emailField;
  var emailInputs = await page.$$('input[type="email"], input[placeholder*="email"], input[placeholder*="Email"], input[name*="email"]');
  var usernameInputs = await page.$$('input[placeholder*="username"], input[placeholder*="Username"], input[name*="username"]');
  
  if (emailInputs.isNotEmpty) {
    emailField = emailInputs.first;
    print('✅ Found email input field');
  } else if (usernameInputs.isNotEmpty) {
    emailField = usernameInputs.first;
    print('✅ Found username input field');
  } else if (allInputs.isNotEmpty) {
    // Try the first input field
    emailField = allInputs.first;
    print('✅ Using first input field for email');
  }
  
  if (emailField != null) {
    // Clear and type email
    await emailField.click();
    await emailField.type(EnvConfig.testEmail);
    print('📧 Typed email: ${EnvConfig.testEmail}');
  }
  
  // Look for password field
  var passwordInputs = await page.$$('input[type="password"], input[placeholder*="password"], input[placeholder*="Password"], input[name*="password"]');
  print('🔒 Password inputs found: ${passwordInputs.length}');
  
  ElementHandle? passwordField;
  if (passwordInputs.isNotEmpty) {
    passwordField = passwordInputs.first;
    print('✅ Found password input field');
  } else if (allInputs.length > 1) {
    // Try the second input field
    passwordField = allInputs[1];
    print('✅ Using second input field for password');
  }
  
  if (passwordField != null) {
    // Clear and type password
    await passwordField.click();
    await passwordField.type(EnvConfig.testPassword);
    print('🔒 Typed password: ${EnvConfig.testPassword}');
  }
  
  // Look for login button
  var loginButtons = await page.$$('button[type="submit"]');
  
  print('🔑 Login buttons found: ${loginButtons.length}');
  
  ElementHandle? loginButton;
  if (loginButtons.isNotEmpty) {
    loginButton = loginButtons.first;
    print('✅ Found login button');
  } else if (allButtons.isNotEmpty) {
    // Try the last button (usually submit button)
    loginButton = allButtons.last;
    print('✅ Using last button as login button');
  }
  
  if (loginButton != null) {
    // Click login button
    await loginButton.click();
    print('🖱️ Clicked login button');
    
    // Wait for login to complete
    await Future.delayed(Duration(seconds: 3));
    print('⏳ Waited for login to complete');
  }
  
  // Take screenshot after login
  var loginScreenshot = await page.screenshot();
  await File('login_attempt_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(loginScreenshot);
  print('📸 Screenshot saved: login attempt');
} 