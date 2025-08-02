import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  var browser = await puppeteer.launch(headless: false);
  var page = await browser.newPage();

  try {
    print('🧪 Starting advanced Flutter web app test...');

    // Navigate to your Flutter web app
    await page.goto('http://localhost:3000', wait: Until.networkIdle);
    print('✅ Loaded Flutter web app');

    // Wait for app to be ready
    await page.waitForSelector('body', timeout: Duration(seconds: 10));
    
    // Take initial screenshot
    var initialScreenshot = await page.screenshot();
    await File('test/web/initial_state.png').writeAsBytes(initialScreenshot);
    print('📸 Initial state screenshot saved');

    // Test 1: Look for login elements and try to interact
    await _testLoginFlow(page);

    // Test 2: Check for any navigation or menu elements
    await _testNavigation(page);

    // Test 3: Check for any dynamic content or loading states
    await _testDynamicContent(page);

    print('🎉 Advanced web test completed successfully!');

  } catch (e) {
    print('❌ Advanced test failed: $e');
    
    // Take error screenshot
    try {
      var errorScreenshot = await page.screenshot();
      await File('test/web/advanced_error_screenshot.png').writeAsBytes(errorScreenshot);
      print('📸 Error screenshot saved');
    } catch (screenshotError) {
      print('⚠️ Could not save error screenshot: $screenshotError');
    }
    
    rethrow;
  } finally {
    await browser.close();
  }
}

Future<void> _testLoginFlow(Page page) async {
  print('🔐 Testing login flow...');

  // Look for email input
  try {
    var emailInput = await page.$('input[type="email"], input[placeholder*="email"], input[name*="email"]');
    if (emailInput != null) {
      await emailInput.type('test@example.com');
      print('✅ Typed email address');
    }
  } catch (e) {
    print('⚠️ Email input not found: $e');
  }

  // Look for password input
  try {
    var passwordInput = await page.$('input[type="password"], input[placeholder*="password"], input[name*="password"]');
    if (passwordInput != null) {
      await passwordInput.type('password123');
      print('✅ Typed password');
    }
  } catch (e) {
    print('⚠️ Password input not found: $e');
  }

  // Look for login button
  try {
    var loginButton = await page.$('button:contains("Login"), button:contains("Sign In"), input[type="submit"]');
    if (loginButton != null) {
      await loginButton.click();
      print('✅ Clicked login button');
      
      // Wait for potential navigation or loading
      await Future.delayed(Duration(seconds: 3));
      
      // Take screenshot after login attempt
      var loginScreenshot = await page.screenshot();
      await File('test/web/after_login_attempt.png').writeAsBytes(loginScreenshot);
      print('📸 Post-login screenshot saved');
    }
  } catch (e) {
    print('⚠️ Login button not found: $e');
  }
}

Future<void> _testNavigation(Page page) async {
  print('🧭 Testing navigation...');

  // Look for any navigation elements
  try {
    var navElements = await page.$$('nav, .navigation, .menu, .sidebar');
    if (navElements.isNotEmpty) {
      print('✅ Found ${navElements.length} navigation elements');
    }
  } catch (e) {
    print('⚠️ No navigation elements found: $e');
  }

  // Look for any links
  try {
    var links = await page.$$('a');
    if (links.isNotEmpty) {
      print('✅ Found ${links.length} links');
    }
  } catch (e) {
    print('⚠️ No links found: $e');
  }
}

Future<void> _testDynamicContent(Page page) async {
  print('🔄 Testing dynamic content...');

  // Check for any loading indicators
  try {
    var loadingElements = await page.$$('.loading, .spinner, [class*="loading"], [class*="spinner"]');
    if (loadingElements.isNotEmpty) {
      print('✅ Found ${loadingElements.length} loading elements');
    }
  } catch (e) {
    print('⚠️ No loading elements found: $e');
  }

  // Check for any error messages
  try {
    var errorElements = await page.$$('.error, .alert, [class*="error"], [class*="alert"]');
    if (errorElements.isNotEmpty) {
      print('⚠️ Found ${errorElements.length} error/alert elements');
    }
  } catch (e) {
    print('✅ No error elements found: $e');
  }

  // Check for any success messages
  try {
    var successElements = await page.$$('.success, [class*="success"]');
    if (successElements.isNotEmpty) {
      print('✅ Found ${successElements.length} success elements');
    }
  } catch (e) {
    print('⚠️ No success elements found: $e');
  }
} 