# MCP Puppeteer Testing for Flutter App

This document explains how to use MCP (Model Context Protocol) Puppeteer servers for direct AI assistant browser automation of your Flutter web app.

## 🚀 MCP Servers Added

Three Puppeteer MCP servers have been added to `.cursor/mcp.json`:

1. **MCP_PUPPETEER_ADVANCED** (`@jatidevelopments/mcp-puppeteer-advanced`)
   - Most comprehensive browser automation
   - Full Puppeteer API access
   - Best for complex testing scenarios

2. **MCP_PUPPETEER_VISION** (`@Larsbuilds/puppeteer-vision-mcp-specify4it`)
   - Visual browser interaction
   - Screenshot analysis
   - Computer vision capabilities

3. **MCP_PUPPETEER_REAL_BROWSER** (`@withLinda/puppeteer-real-browser-mcp-server`)
   - Real browser instance control
   - Non-headless browser automation
   - Live interaction capabilities

## 🎯 How It Works

Instead of writing pre-built test scripts, you can now ask the AI assistant to:

### Example Commands:
```
"Navigate to my Flutter app at localhost:3000 and test the login flow"
"Click on the recall game button and verify the game loads"
"Fill out the registration form with test data"
"Take a screenshot of the current state"
"Test the authentication flow with invalid credentials"
"Navigate to the recall game and click the start button"
```

### What the AI Assistant Can Do:
- **Navigate** to your Flutter app
- **Wait** for app to be ready
- **Fill forms** with test data
- **Click buttons** and interact with UI
- **Take screenshots** for visual verification
- **Extract data** from the page
- **Handle errors** and edge cases
- **Test authentication** flows
- **Verify UI elements** are present
- **Test game interactions** in the recall game

## 🔧 Setup Requirements

### 1. Flutter App Running
```bash
# Build and serve the Flutter app
cd flutter_base_05
flutter build web
cd build/web
python3 -m http.server 3000
```

### 2. MCP Configuration
The MCP servers are already configured in `.cursor/mcp.json`:
```json
{
  "mcpServers": {
    "MCP_PUPPETEER_ADVANCED": {
      "command": "npx",
      "args": ["@jatidevelopments/mcp-puppeteer-advanced"]
    },
    "MCP_PUPPETEER_VISION": {
      "command": "npx",
      "args": ["@Larsbuilds/puppeteer-vision-mcp-specify4it"]
    },
    "MCP_PUPPETEER_REAL_BROWSER": {
      "command": "npx",
      "args": ["@withLinda/puppeteer-real-browser-mcp-server"]
    }
  }
}
```

## 🧪 Testing Scenarios

### Basic Navigation
- Navigate to app homepage
- Wait for app initialization
- Verify app is loaded correctly

### Authentication Testing
- Fill login form with test credentials
- Submit form and verify redirect
- Test invalid credentials
- Test password reset flow

### Game Testing
- Navigate to recall game
- Test game initialization
- Click game buttons
- Verify game state changes

### UI Validation
- Check all buttons are clickable
- Verify form validation
- Test responsive design
- Check accessibility features

### Error Handling
- Test network errors
- Test invalid input
- Verify error messages
- Test recovery flows

## 📸 Screenshot and Visual Testing

The MCP servers can:
- Take screenshots at any point
- Compare screenshots with baselines
- Analyze visual elements
- Detect UI changes
- Verify visual consistency

## 🔍 Debugging

### Common Issues:
1. **App not loading**: Check if Flutter app is running on port 3000
2. **Authentication issues**: Verify test credentials in `test_config.env`
3. **Element not found**: Check if app is fully loaded before interaction
4. **Network errors**: Ensure backend services are running

### Debug Commands:
```
"Take a screenshot of the current state"
"Show me the page source"
"What elements are visible on the page?"
"Click on the first button you can find"
```

## 🎮 Example: Testing Recall Game

Here's how you could test the recall game:

1. **Navigate to game**: "Go to localhost:3000/#/recall/lobby"
2. **Wait for load**: "Wait for the game interface to appear"
3. **Start game**: "Click the start game button"
4. **Test gameplay**: "Click on the game cards as they appear"
5. **Verify score**: "Check if the score is being updated"
6. **Take screenshot**: "Take a screenshot of the game in progress"

## 🚀 Benefits Over Traditional Testing

### Traditional Testing:
- ❌ Requires pre-written test scripts
- ❌ Static test cases
- ❌ Limited to predefined scenarios
- ❌ Manual test maintenance

### MCP Puppeteer Testing:
- ✅ Dynamic test creation
- ✅ Natural language commands
- ✅ Real-time interaction
- ✅ Visual verification
- ✅ AI-powered debugging
- ✅ No pre-built tests needed

## 📋 Next Steps

1. **Start your Flutter app** on localhost:3000
2. **Ask the AI assistant** to test your app
3. **Try different scenarios** like login, game testing, etc.
4. **Use screenshots** for visual verification
5. **Debug issues** with natural language commands

## 🔗 Related Files

- `.cursor/mcp.json` - MCP server configuration
- `test_config.env` - Test credentials and URLs
- `puppeteer_direct_test.js` - Example direct Puppeteer usage
- `mcp_test_example.js` - MCP usage examples

---

**Ready to test?** Just ask the AI assistant: *"Navigate to my Flutter app and test the login functionality"* 