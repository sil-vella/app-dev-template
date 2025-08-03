# MCP Server Setup Guide

This guide explains how to set up and use the MCP (Model Context Protocol) servers for browser automation testing of your Flutter app.

## 🚀 Available MCP Servers

### 1. MCP_PUPPETEER
- **Package**: `@modelcontextprotocol/server-puppeteer`
- **Status**: ✅ Working
- **Features**: Basic browser automation, navigation, screenshots, form filling
- **Configuration**: Already configured in `.cursor/mcp.json`

### 2. MCP_PUPPETEER_VISION
- **Package**: `puppeteer-vision-mcp-server`
- **Status**: ✅ Working (requires OpenAI API key)
- **Features**: AI-powered browser interaction, visual analysis, automatic form handling
- **Configuration**: Requires OpenAI API key setup

## 🔧 Setup Instructions

### Step 1: Basic Puppeteer MCP (No API Key Required)

The basic Puppeteer MCP server is already configured and ready to use:

```json
"MCP_PUPPETEER": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-puppeteer"],
  "env": {
    "PUPPETEER_LAUNCH_OPTIONS": "{ \"headless\": false, \"defaultViewport\": { \"width\": 1280, \"height\": 720 } }",
    "ALLOW_DANGEROUS": "true"
  }
}
```

### Step 2: Vision Puppeteer MCP (Requires OpenAI API Key)

To use the vision-powered Puppeteer MCP server:

1. **Get an OpenAI API Key**:
   - Go to [OpenAI Platform](https://platform.openai.com/api-keys)
   - Create a new API key
   - Copy the key

2. **Update the Configuration**:
   Replace `"your_openai_api_key_here"` in `.cursor/mcp.json` with your actual API key:

   ```json
   "MCP_PUPPETEER_VISION": {
     "command": "npx",
     "args": ["-y", "puppeteer-vision-mcp-server"],
     "env": {
       "OPENAI_API_KEY": "sk-your-actual-api-key-here",
       "VISION_MODEL": "gpt-4o",
       "DISABLE_HEADLESS": "true"
     }
   }
   ```

## 🧪 Testing Your Flutter App

### Using Basic Puppeteer MCP

Once configured, you can ask the AI assistant to:

```
"Navigate to my Flutter app at localhost:3000 and test the login flow"
"Take a screenshot of the current page"
"Fill out the login form with test credentials"
"Click on the recall game button"
"Navigate to the recall game and test the game interface"
```

### Using Vision Puppeteer MCP

With the vision MCP server, you can ask the AI assistant to:

```
"Scrape my Flutter app at localhost:3000 and analyze the content"
"Navigate to the app and automatically handle any popups or consent forms"
"Test the authentication flow by analyzing the visual elements"
"Extract and analyze the game interface from the recall game"
```

## 🎯 Example Commands

### Basic Navigation
```
"Navigate to localhost:3000 and wait for the app to load"
```

### Authentication Testing
```
"Go to localhost:3000, find the login form, fill it with test credentials, and submit"
```

### Game Testing
```
"Navigate to localhost:3000/#/recall/lobby, wait for the game to load, and click the start button"
```

### Visual Analysis
```
"Take a screenshot of the current page and analyze what elements are visible"
```

### Form Testing
```
"Find all input fields on the page and fill them with appropriate test data"
```

## 🔍 Troubleshooting

### Common Issues:

1. **MCP servers not showing tools**:
   - Restart Cursor/VS Code
   - Check if the packages are installed correctly
   - Verify the configuration in `.cursor/mcp.json`

2. **Vision MCP not working**:
   - Ensure you have a valid OpenAI API key
   - Check that the API key has sufficient credits
   - Verify the `VISION_MODEL` is set correctly

3. **Browser not launching**:
   - Check if Chrome/Chromium is installed
   - Verify the `PUPPETEER_LAUNCH_OPTIONS` configuration
   - Try setting `"headless": false` to see the browser

4. **Flutter app not accessible**:
   - Ensure your Flutter app is running on localhost:3000
   - Check that the app is built and served correctly
   - Verify no firewall is blocking the connection

### Debug Commands:

```
"Check if the MCP servers are available"
"List all available tools"
"Test the browser connection"
"Take a screenshot to verify the page loaded"
```

## 📋 Next Steps

1. **Start your Flutter app**:
   ```bash
   cd flutter_base_05
   flutter build web
   cd build/web
   python3 -m http.server 3000
   ```

2. **Test the MCP servers**:
   - Ask the AI assistant to navigate to your app
   - Test basic interactions like clicking buttons
   - Try form filling and navigation

3. **Use advanced features**:
   - With vision MCP: Test AI-powered interactions
   - Take screenshots for visual verification
   - Analyze page content and structure

## 🔗 Related Files

- `.cursor/mcp.json` - MCP server configuration
- `test_config.env` - Test credentials and URLs
- `MCP_TESTING.md` - Detailed testing documentation
- `puppeteer_direct_test.js` - Example direct Puppeteer usage

---

**Ready to test?** Start your Flutter app and ask the AI assistant: *"Navigate to my Flutter app and test the login functionality"* 