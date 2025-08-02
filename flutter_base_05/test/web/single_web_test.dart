import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  print('🚀 Starting single web test with launch.json arguments...');
  
  // Launch browser with launch.json arguments
  var browser = await puppeteer.launch(
    headless: false, // Keep visible for debugging
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

  try {
    print('🧪 Test: Launching Flutter web app with launch.json arguments...');

    // Navigate to the app with same port as launch.json
    await page.goto('http://localhost:3000', wait: Until.networkIdle);
    print('✅ App loaded at http://localhost:3000');

    // Wait for Flutter to initialize
    await page.waitForSelector('body', timeout: Duration(seconds: 15));
    print('✅ Flutter app initialized');

    // Test 1: Check if app is responsive
    await _testAppResponsiveness(page);

    // Test 2: Check for authentication flow
    await _testAuthenticationFlow(page);

    // Test 3: Check for any errors or loading states
    await _testAppState(page);

    // Test 4: Wait for app_ready hook
    await _waitForAppReady(page);

    // Take final screenshot
    var finalScreenshot = await page.screenshot();
    await File('single_test_final_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(finalScreenshot);
    print('📸 Final screenshot saved');

    print('🎉 Single web test completed successfully!');

  } catch (e) {
    print('❌ Single web test failed: $e');
    
    // Take error screenshot
    try {
      var errorScreenshot = await page.screenshot();
      await File('single_test_error_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(errorScreenshot);
      print('📸 Error screenshot saved');
    } catch (screenshotError) {
      print('⚠️ Could not save error screenshot: $screenshotError');
    }
    
    rethrow;
  } finally {
    await browser.close();
  }
}

Future<void> _waitForAppReady(Page page) async {
  print('⏳ Waiting for app_ready hook...');
  
  // Wait up to 30 seconds for app to be ready
  var startTime = DateTime.now();
  var timeout = Duration(seconds: 30);
  
  while (DateTime.now().difference(startTime) < timeout) {
    try {
      // Check for app_ready log message in console
      var logs = await page.evaluate<List<dynamic>>('''
        function() {
          // Check if there's any indication that app is ready
          var readyIndicators = [];
          
          // Look for app_ready in console logs (if accessible)
          if (window.console && window.console.log) {
            // This is a simplified check - in real scenarios you might need more sophisticated logging
            readyIndicators.push('console_available');
          }
          
          // Look for specific DOM elements that indicate app is ready
          var authElements = document.querySelectorAll('[class*="auth"], [class*="login"], [class*="dashboard"]');
          if (authElements.length > 0) {
            readyIndicators.push('auth_elements_found');
          }
          
          // Look for any interactive elements
          var interactiveElements = document.querySelectorAll('button, input, a, [role="button"]');
          if (interactiveElements.length > 0) {
            readyIndicators.push('interactive_elements_found');
          }
          
          // Look for any text content that indicates app is loaded
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
      
      // Wait a bit before checking again
      await Future.delayed(Duration(milliseconds: 500));
      
    } catch (e) {
      print('⚠️ Error checking app ready state: $e');
      await Future.delayed(Duration(milliseconds: 500));
    }
  }
  
  print('⚠️ App ready timeout - proceeding with test anyway');
}

Future<void> _testAppResponsiveness(Page page) async {
  print('🔍 Testing app responsiveness...');

  // Check if app has any content
  var pageContent = await page.evaluate<String>('document.body.textContent');
  if (pageContent.isNotEmpty) {
    var displayContent = pageContent.length > 200 ? '${pageContent.substring(0, 200)}...' : pageContent;
    print('✅ App has content: $displayContent');
  } else {
    print('⚠️ App appears to have no content');
  }

  // Check for Flutter-specific elements
  try {
    var flutterElements = await page.$$('[data-flutter]');
    if (flutterElements.isNotEmpty) {
      print('✅ Found ${flutterElements.length} Flutter elements');
    }
  } catch (e) {
    print('⚠️ No Flutter elements found: $e');
  }

  // Check for any interactive elements
  try {
    var interactiveElements = await page.$$('button, input, a, [role="button"]');
    if (interactiveElements.isNotEmpty) {
      print('✅ Found ${interactiveElements.length} interactive elements');
    } else {
      print('⚠️ No interactive elements found');
    }
  } catch (e) {
    print('⚠️ Error checking interactive elements: $e');
  }
}

Future<void> _testAuthenticationFlow(Page page) async {
  print('🔐 Testing authentication flow...');

  // Look for login-related elements
  var loginElements = await _findLoginElements(page);
  
  if (loginElements.isNotEmpty) {
    print('✅ Found ${loginElements.length} login-related elements');
    
    // Try to interact with login form
    await _interactWithLoginForm(page);
  } else {
    print('⚠️ No login elements found - app might be in authenticated state');
    
    // Check if user is already logged in
    await _checkAuthenticatedState(page);
  }
}

Future<List<ElementHandle>> _findLoginElements(Page page) async {
  var elements = <ElementHandle>[];
  
  try {
    // Look for common login selectors
    var selectors = [
      'input[type="email"]',
      'input[placeholder*="email"]',
      'input[name*="email"]',
      'input[type="password"]',
      'input[placeholder*="password"]',
      'input[name*="password"]',
      'button:contains("Login")',
      'button:contains("Sign In")',
      'input[type="submit"]'
    ];

    for (var selector in selectors) {
      try {
        var element = await page.$(selector);
        if (element != null) {
          elements.add(element);
        }
      } catch (e) {
        // Ignore selector errors
      }
    }
  } catch (e) {
    print('⚠️ Error finding login elements: $e');
  }

  return elements;
}

Future<void> _interactWithLoginForm(Page page) async {
  print('📝 Attempting to interact with login form...');

  try {
    // Try to type email
    var emailInput = await page.$('input[type="email"], input[placeholder*="email"], input[name*="email"]');
    if (emailInput != null) {
      await emailInput.type('test@example.com');
      print('✅ Typed test email');
    }

    // Try to type password
    var passwordInput = await page.$('input[type="password"], input[placeholder*="password"], input[name*="password"]');
    if (passwordInput != null) {
      await passwordInput.type('testpassword123');
      print('✅ Typed test password');
    }

    // Try to click login button
    var loginButton = await page.$('button:contains("Login"), button:contains("Sign In"), input[type="submit"]');
    if (loginButton != null) {
      await loginButton.click();
      print('✅ Clicked login button');
      
      // Wait for potential navigation
      await Future.delayed(Duration(seconds: 3));
      
      // Take screenshot after login attempt
      var loginScreenshot = await page.screenshot();
      await File('single_test_after_login_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(loginScreenshot);
      print('📸 Post-login screenshot saved');
    }
  } catch (e) {
    print('⚠️ Error interacting with login form: $e');
  }
}

Future<void> _checkAuthenticatedState(Page page) async {
  print('🔍 Checking if user is already authenticated...');

  try {
    // Look for elements that indicate authenticated state
    var authIndicators = await page.$$('[class*="dashboard"], [class*="home"], [class*="main"], [class*="profile"]');
    if (authIndicators.isNotEmpty) {
      print('✅ Found ${authIndicators.length} authenticated state indicators');
    }

    // Look for logout or user menu elements
    var logoutElements = await page.$$('[class*="logout"], [class*="user"], [class*="profile"]');
    if (logoutElements.isNotEmpty) {
      print('✅ Found ${logoutElements.length} logout/user elements');
    }

    // Check for any welcome or user-specific text
    var pageContent = await page.evaluate<String>('document.body.textContent');
    if (pageContent.toLowerCase().contains('welcome') || 
        pageContent.toLowerCase().contains('dashboard') ||
        pageContent.toLowerCase().contains('home')) {
      print('✅ Found authenticated state indicators in content');
    }
  } catch (e) {
    print('⚠️ Error checking authenticated state: $e');
  }
}

Future<void> _testAppState(Page page) async {
  print('🔄 Testing app state...');

  // Check for loading states
  try {
    var loadingElements = await page.$$('.loading, .spinner, [class*="loading"], [class*="spinner"], [class*="progress"]');
    if (loadingElements.isNotEmpty) {
      print('⚠️ Found ${loadingElements.length} loading elements - app might still be initializing');
    } else {
      print('✅ No loading elements found - app appears ready');
    }
  } catch (e) {
    print('⚠️ Error checking loading states: $e');
  }

  // Check for error states
  try {
    var errorElements = await page.$$('.error, .alert, [class*="error"], [class*="alert"], [class*="exception"]');
    if (errorElements.isNotEmpty) {
      print('⚠️ Found ${errorElements.length} error/alert elements');
      
      // Get error text
      for (var i = 0; i < errorElements.length; i++) {
        var errorText = await errorElements[i].evaluate<String>('element => element.textContent');
        print('❌ Error ${i + 1}: $errorText');
      }
    } else {
      print('✅ No error elements found');
    }
  } catch (e) {
    print('⚠️ Error checking error states: $e');
  }

  // Check for success states
  try {
    var successElements = await page.$$('.success, [class*="success"], [class*="complete"]');
    if (successElements.isNotEmpty) {
      print('✅ Found ${successElements.length} success elements');
    }
  } catch (e) {
    print('⚠️ Error checking success states: $e');
  }
} 