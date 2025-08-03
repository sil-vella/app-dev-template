const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

// Load environment variables from test_config.env
function loadEnvConfig() {
  const envPath = path.join(__dirname, 'test_config.env');
  const envContent = fs.readFileSync(envPath, 'utf8');
  const config = {};
  
  envContent.split('\n').forEach(line => {
    const [key, value] = line.split('=');
    if (key && value) {
      config[key.trim()] = value.trim();
    }
  });
  
  return config;
}

async function runDirectTest() {
  const config = loadEnvConfig();
  
  console.log('🚀 Starting direct Puppeteer test...');
  console.log('📋 Test configuration:', {
    baseUrl: config.TEST_BASE_URL,
    email: config.TEST_EMAIL,
    timeout: config.APP_READY_TIMEOUT
  });

  const browser = await puppeteer.launch({
    headless: false, // Set to true for headless mode
    args: [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-accelerated-2d-canvas',
      '--no-first-run',
      '--no-zygote',
      '--disable-gpu',
      '--disable-web-security',
      '--disable-features=VizDisplayCompositor'
    ]
  });

  try {
    const page = await browser.newPage();
    
    // Set viewport
    await page.setViewport({ width: 1280, height: 720 });
    
    // Navigate to the app
    console.log('🌐 Navigating to app...');
    await page.goto(config.TEST_BASE_URL, { 
      waitUntil: 'networkidle2',
      timeout: parseInt(config.APP_READY_TIMEOUT) * 1000 
    });
    
    // Wait for app to be ready
    console.log('⏳ Waiting for app to be ready...');
    await page.waitForFunction(() => {
      return window.appReady === true || 
             document.querySelector('[data-testid="app-ready"]') !== null ||
             document.body.textContent.includes('Recall Game');
    }, { timeout: parseInt(config.APP_READY_TIMEOUT) * 1000 });
    
    console.log('✅ App is ready!');
    
    // Take a screenshot
    await page.screenshot({ 
      path: path.join(__dirname, 'test_screenshot_initial.png'),
      fullPage: true 
    });
    console.log('📸 Screenshot saved: test_screenshot_initial.png');
    
    // Check if we need to login
    const currentUrl = page.url();
    console.log('🔍 Current URL:', currentUrl);
    
    if (currentUrl.includes('/account') || currentUrl.includes('/auth')) {
      console.log('🔐 Detected login required, performing login...');
      await performLogin(page, config);
    }
    
    // Navigate to recall game
    console.log('🎮 Navigating to recall game...');
    await page.goto(config.TEST_RECALL_GAME_URL, { 
      waitUntil: 'networkidle2' 
    });
    
    // Wait for recall game to load
    await page.waitForTimeout(3000);
    
    // Take another screenshot
    await page.screenshot({ 
      path: path.join(__dirname, 'test_screenshot_recall_game.png'),
      fullPage: true 
    });
    console.log('📸 Screenshot saved: test_screenshot_recall_game.png');
    
    // Test some UI interactions
    console.log('🖱️ Testing UI interactions...');
    
    // Look for buttons and click them
    const buttons = await page.$$('button');
    console.log(`Found ${buttons.length} buttons`);
    
    // Look for input fields
    const inputs = await page.$$('input');
    console.log(`Found ${inputs.length} input fields`);
    
    // Look for specific elements
    const elements = await page.$$('div, span, a');
    console.log(`Found ${elements.length} div/span/a elements`);
    
    // Test clicking on elements (be careful not to break the app)
    try {
      // Look for a safe element to click (like a navigation link)
      const navLinks = await page.$$('a[href]');
      if (navLinks.length > 0) {
        console.log('🔗 Clicking on first navigation link...');
        await navLinks[0].click();
        await page.waitForTimeout(1000);
      }
    } catch (error) {
      console.log('⚠️ Could not click navigation link:', error.message);
    }
    
    // Test form input if available
    const emailInputs = await page.$$('input[type="email"]');
    const textInputs = await page.$$('input[type="text"]');
    
    if (emailInputs.length > 0) {
      console.log('📝 Testing email input...');
      await emailInputs[0].type('test@example.com');
      await page.waitForTimeout(500);
    }
    
    if (textInputs.length > 0) {
      console.log('📝 Testing text input...');
      await textInputs[0].type('Test input');
      await page.waitForTimeout(500);
    }
    
    // Final screenshot
    await page.screenshot({ 
      path: path.join(__dirname, 'test_screenshot_final.png'),
      fullPage: true 
    });
    console.log('📸 Final screenshot saved: test_screenshot_final.png');
    
    console.log('✅ Direct Puppeteer test completed successfully!');
    
  } catch (error) {
    console.error('❌ Test failed:', error);
    await page.screenshot({ 
      path: path.join(__dirname, 'test_screenshot_error.png'),
      fullPage: true 
    });
    console.log('📸 Error screenshot saved: test_screenshot_error.png');
  } finally {
    await browser.close();
    console.log('🔚 Browser closed');
  }
}

async function performLogin(page, config) {
  try {
    // Wait for login form
    await page.waitForSelector('input[type="email"], input[name="email"]', { timeout: 10000 });
    
    // Fill email
    await page.type('input[type="email"], input[name="email"]', config.TEST_EMAIL);
    console.log('📧 Email entered');
    
    // Fill password
    await page.type('input[type="password"], input[name="password"]', config.TEST_PASSWORD);
    console.log('🔒 Password entered');
    
    // Click login button
    const loginButton = await page.$('button[type="submit"], button:contains("Login"), button:contains("Sign In")');
    if (loginButton) {
      await loginButton.click();
      console.log('🔑 Login button clicked');
      
      // Wait for navigation
      await page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 10000 });
      console.log('✅ Login successful');
    } else {
      console.log('⚠️ Login button not found, trying form submit');
      await page.evaluate(() => {
        const form = document.querySelector('form');
        if (form) form.submit();
      });
    }
    
  } catch (error) {
    console.error('❌ Login failed:', error.message);
    throw error;
  }
}

// Run the test
if (require.main === module) {
  runDirectTest().catch(console.error);
}

module.exports = { runDirectTest, performLogin }; 