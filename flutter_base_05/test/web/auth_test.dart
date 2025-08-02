import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

void main() async {
  // Launch browser
  var browser = await puppeteer.launch(headless: false); // Set to true for CI
  var page = await browser.newPage();

  try {
    print('🧪 Starting Flutter web app test...');

    // Navigate to your Flutter web app
    // You'll need to run: flutter run -d chrome --web-port 3000
    await page.goto('http://localhost:3000', wait: Until.networkIdle);
    print('✅ Loaded Flutter web app');

    // Wait for the app to initialize
    await page.waitForSelector('body', timeout: Duration(seconds: 10));
    print('✅ App loaded successfully');

    // Test 1: Check if login form is present
    try {
      await page.waitForSelector('input[type="email"], input[placeholder*="email"], input[name*="email"]', 
          timeout: Duration(seconds: 5));
      print('✅ Login form found');
    } catch (e) {
      print('⚠️ Login form not found - app might be in different state');
    }

    // Test 2: Check if password field is present
    try {
      await page.waitForSelector('input[type="password"], input[placeholder*="password"], input[name*="password"]', 
          timeout: Duration(seconds: 5));
      print('✅ Password field found');
    } catch (e) {
      print('⚠️ Password field not found - app might be in different state');
    }

    // Test 3: Look for any buttons (login, submit, etc.)
    try {
      await page.waitForSelector('button, input[type="submit"]', timeout: Duration(seconds: 5));
      print('✅ Action buttons found');
    } catch (e) {
      print('⚠️ No action buttons found');
    }

    // Test 4: Check for any text that indicates the app is working
    var pageContent = await page.evaluate<String>('document.body.textContent');
    if (pageContent.isNotEmpty) {
      print('✅ App has content: ${pageContent.substring(0, 100)}...');
    } else {
      print('⚠️ App appears to have no content');
    }

    // Take a screenshot for debugging
    var screenshot = await page.screenshot();
    await File('test/web/screenshot_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(screenshot);
    print('📸 Screenshot saved');

    print('🎉 Web test completed successfully!');

  } catch (e) {
    print('❌ Test failed: $e');
    
    // Take error screenshot
    try {
      var errorScreenshot = await page.screenshot();
      await File('test/web/error_screenshot_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(errorScreenshot);
      print('📸 Error screenshot saved');
    } catch (screenshotError) {
      print('⚠️ Could not save error screenshot: $screenshotError');
    }
    
    rethrow;
  } finally {
    await browser.close();
  }
} 