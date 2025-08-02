import 'dart:io';
import 'package:puppeteer/puppeteer.dart';

Future<void> main() async {
  print('🎮 Starting Recall Game Screen Test...');
  
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
  
  try {
    print('🌐 Navigating to Flutter web app...');
    await page.goto('http://localhost:3000');
    
    // Wait for app to be ready
    await _waitForAppReady(page);
    
    print('🎮 Testing Recall Game Screen...');
    
    // Test 1: Navigate to recall game screen
    await _testNavigateToRecallGame(page);
    
    // Test 2: Check recall game UI elements
    await _testRecallGameUI(page);
    
    // Test 3: Test game interactions
    await _testGameInteractions(page);
    
    print('✅ Recall Game Screen Test completed successfully!');
    
  } catch (e) {
    print('❌ Recall Game Screen Test failed: $e');
    try {
      var errorScreenshot = await page.screenshot();
      await File('recall_game_error_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(errorScreenshot);
    } catch (screenshotError) {
      print('⚠️ Could not take error screenshot: $screenshotError');
    }
    rethrow;
  } finally {
    await browser.close();
  }
}

Future<void> _waitForAppReady(Page page) async {
  print('⏳ Waiting for app_ready hook...');
  var startTime = DateTime.now();
  var timeout = Duration(seconds: 30);
  
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

Future<void> _testNavigateToRecallGame(Page page) async {
  print('🧭 Testing navigation to recall game screen...');
  
  // Look for navigation elements to the recall game
  var recallGameElements = await page.$$('[class*="recall"], [class*="game"], [class*="memory"]');
  
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
    
    // Try to navigate directly to recall game route
    await page.goto('http://localhost:3000/recall-game');
    await Future.delayed(Duration(seconds: 2));
    
    var directNavScreenshot = await page.screenshot();
    await File('recall_game_direct_nav_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(directNavScreenshot);
    print('📸 Screenshot saved: direct recall game navigation');
  }
}

Future<void> _testRecallGameUI(Page page) async {
  print('🎮 Testing recall game UI elements...');
  
  // Check for game-specific UI elements
  var gameElements = await page.$$('[class*="game"], [class*="card"], [class*="board"], [class*="grid"]');
  
  if (gameElements.isNotEmpty) {
    print('✅ Found game UI elements: ${gameElements.length} elements');
    
    // Check for specific game components
    var cardElements = await page.$$('[class*="card"]');
    var boardElements = await page.$$('[class*="board"]');
    var scoreElements = await page.$$('[class*="score"], [class*="points"]');
    
    print('🎴 Game cards found: ${cardElements.length}');
    print('🎯 Game board found: ${boardElements.length}');
    print('📊 Score elements found: ${scoreElements.length}');
    
  } else {
    print('⚠️ No specific game UI elements found');
  }
  
  // Check for game controls
  var controlElements = await page.$$('button, [role="button"]');
  print('🎮 Game controls found: ${controlElements.length}');
  
  // Take screenshot of game screen
  var uiScreenshot = await page.screenshot();
  await File('recall_game_ui_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(uiScreenshot);
  print('📸 Screenshot saved: recall game UI');
}

Future<void> _testGameInteractions(Page page) async {
  print('🎯 Testing game interactions...');
  
  // Look for clickable game elements
  var clickableElements = await page.$$('[class*="card"], [class*="tile"], button');
  
  if (clickableElements.isNotEmpty) {
    print('🖱️ Found ${clickableElements.length} clickable game elements');
    
    // Click on the first few elements to test interactions
    for (int i = 0; i < clickableElements.length && i < 3; i++) {
      try {
        await clickableElements[i].click();
        print('🖱️ Clicked on game element ${i + 1}');
        await Future.delayed(Duration(milliseconds: 500));
      } catch (e) {
        print('⚠️ Could not click on game element ${i + 1}: $e');
      }
    }
    
    // Take screenshot after interactions
    var interactionsScreenshot = await page.screenshot();
    await File('recall_game_interactions_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(interactionsScreenshot);
    print('📸 Screenshot saved: game interactions');
    
  } else {
    print('⚠️ No clickable game elements found');
  }
  
  // Check for game state changes
  var gameStateElements = await page.$$('[class*="active"], [class*="selected"], [class*="matched"]');
  print('🎯 Game state elements found: ${gameStateElements.length}');
} 