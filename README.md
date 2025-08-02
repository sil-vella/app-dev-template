# App Development Template

A comprehensive development template featuring a Flutter mobile app with a Python Flask backend, complete with automated testing and deployment infrastructure.

## 🏗️ Project Structure

```
app_dev/
├── flutter_base_05/          # Flutter mobile application
│   ├── lib/                  # Flutter source code
│   ├── test/                 # Flutter tests
│   │   └── web/             # Web testing with Puppeteer
│   └── run_web_test.sh      # Automated web testing script
├── python_base_04/           # Python Flask backend
│   ├── app.py               # Main Flask application
│   ├── core/                # Core backend components
│   └── tools/               # Development tools
└── .vscode/                 # VS Code configuration
```

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK** (latest stable)
- **Python 3.8+**
- **Node.js** (for Puppeteer testing)
- **Docker** (optional, for containerized development)

### Flutter App Setup

```bash
cd flutter_base_05

# Install dependencies
flutter pub get

# Run the app
flutter run

# Run web tests
./run_web_test.sh
```

### Python Backend Setup

```bash
cd python_base_04

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the Flask app
python app.py
```

## 🧪 Testing

### Flutter Web Testing

The project includes automated web testing using Puppeteer:

```bash
cd flutter_base_05
./run_web_test.sh
```

**Features:**
- ✅ **Single Chrome window** testing
- ✅ **App ready hook** detection
- ✅ **Screenshot capture** for debugging
- ✅ **Authentication flow** testing
- ✅ **Responsive design** testing

### Test Results

The test script:
1. **Builds** the Flutter web app
2. **Serves** it on localhost:3000
3. **Launches** Puppeteer Chrome
4. **Tests** app functionality
5. **Captures** screenshots
6. **Waits** for app_ready hook

## 🏗️ Architecture

### Flutter App (`flutter_base_05/`)

**Manager-Based Architecture:**
- `AppManager` - Application lifecycle
- `AuthManager` - Authentication handling
- `StateManager` - State management
- `ModuleManager` - Module coordination
- `HooksManager` - Event system

**Key Features:**
- 🔐 **JWT Authentication**
- 🎮 **Recall Game Core**
- 📱 **AdMob Integration**
- 💳 **Stripe Payments**
- 🌐 **WebSocket Support**

### Python Backend (`python_base_04/`)

**Manager-Based Architecture:**
- `AppManager` - Application orchestrator
- `DatabaseManager` - Database operations
- `RedisManager` - Caching and sessions
- `JWTManager` - Token management
- `VaultManager` - Secret management

**Key Features:**
- 🔐 **JWT Authentication**
- 🗄️ **Database Management**
- 💾 **Redis Caching**
- 🔒 **Vault Integration**
- ⚡ **Rate Limiting**

## 🎯 Development Workflow

### 1. Start Backend
```bash
cd python_base_04
python app.py
```

### 2. Start Flutter App
```bash
cd flutter_base_05
flutter run -d chrome --web-port=3000
```

### 3. Run Tests
```bash
cd flutter_base_05
./run_web_test.sh
```

## 📁 Key Files

### Flutter
- `lib/main.dart` - App entry point
- `lib/core/managers/` - Manager classes
- `test/web/single_web_test.dart` - Web testing
- `run_web_test.sh` - Test automation

### Python
- `python_base_04/app.py` - Flask application
- `python_base_04/core/managers/` - Manager classes
- `python_base_04/tools/logger/` - Logging utilities

## 🔧 Configuration

### VS Code Launch Configurations

The `.vscode/launch.json` includes configurations for:
- **Flutter Debug** - Mobile development
- **Flutter Web** - Web development
- **Flask Debug** - Backend development
- **Testing Mode** - Automated testing

### Environment Variables

Key environment variables:
- `API_URL_LOCAL` - Local backend URL
- `WS_URL_LOCAL` - Local WebSocket URL
- `JWT_*` - JWT configuration
- `ADMOBS_*` - AdMob configuration

## 🚀 Deployment

### Flutter App
```bash
# Build for web
flutter build web

# Build for Android
flutter build apk

# Build for iOS
flutter build ios
```

### Python Backend
```bash
# Using Docker
docker-compose up -d

# Using Python directly
python app.py
```

## 🧪 Testing Strategy

### Web Testing with Puppeteer
- **Single Chrome window** approach
- **App ready hook** detection
- **Screenshot capture** for debugging
- **Authentication flow** testing

### Test Automation
- **Automated build** and serve
- **Port conflict** resolution
- **Timeout handling** for app initialization
- **Error screenshot** capture

## 📊 Monitoring

### Logs
- **Flutter logs** in console
- **Python logs** in `python_base_04/tools/logger/`
- **Test logs** in console output

### Screenshots
- **Test screenshots** in `flutter_base_05/test/web/`
- **Error screenshots** for debugging
- **Final state** screenshots

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** with `./run_web_test.sh`
5. **Commit** your changes
6. **Push** to your branch
7. **Create** a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the **logs** for error messages
2. Review the **screenshots** for visual issues
3. Run the **test script** to reproduce issues
4. Check the **app_ready hook** for initialization problems

---

**Built with ❤️ using Flutter and Python** 