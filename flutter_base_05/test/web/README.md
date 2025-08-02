# Flutter Web Testing with Puppeteer

This directory contains web-based tests for your Flutter app using Puppeteer.

## 🎯 **Why Web Testing?**

Since Flutter is multi-platform, you can test the same business logic and UI components on web that you use on mobile. This provides:

- ✅ **Faster Development** - No device/emulator setup needed
- ✅ **Same Logic** - Core functionality is identical across platforms
- ✅ **Easy CI/CD** - Can run in any environment with Chrome
- ✅ **Visual Testing** - Screenshots and visual verification

## 🚀 **How to Run**

### 1. Start Your Flutter Web App

```bash
# Run your Flutter app on web
flutter run -d chrome --web-port 3000
```

### 2. Run the Web Tests

```bash
# Run basic auth test
dart test/web/auth_test.dart

# Run advanced auth flow test
dart test/web/auth_flow_test.dart
```

## 📁 **Test Files**

- `auth_test.dart` - Basic app loading and element detection
- `auth_flow_test.dart` - Advanced user interaction testing

## 📸 **Screenshots**

Tests automatically save screenshots to:
- `test/web/screenshot_*.png` - Normal screenshots
- `test/web/error_screenshot_*.png` - Error screenshots
- `test/web/initial_state.png` - App initial state
- `test/web/after_login_attempt.png` - After login interaction

## 🎯 **What Gets Tested**

- ✅ **App Loading** - Does the app load properly?
- ✅ **UI Elements** - Are login forms, buttons, etc. present?
- ✅ **User Interactions** - Can users type, click, navigate?
- ✅ **Visual States** - Screenshots of different app states
- ✅ **Error Handling** - How does the app handle errors?

## 🔧 **Customization**

You can modify the tests to:
- Test specific features of your app
- Add more user interaction scenarios
- Test different authentication flows
- Add visual regression testing

## 🎉 **Benefits**

1. **Same Business Logic** - Test your auth, API calls, state management
2. **Faster Feedback** - No device setup or compilation delays
3. **Visual Verification** - See exactly what users see
4. **CI/CD Friendly** - Easy to integrate into automated testing

## 🚀 **Next Steps**

1. Run your Flutter app on web: `flutter run -d chrome --web-port 3000`
2. Run the tests: `dart test/web/auth_test.dart`
3. Check the screenshots in `test/web/` directory
4. Customize tests for your specific app features 