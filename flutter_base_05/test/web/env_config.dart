import 'dart:io';

/// Configuration loader for test environment variables
class EnvConfig {
  static Map<String, String>? _config;
  
  /// Load configuration from test_config.env file
  static Future<Map<String, String>> loadConfig() async {
    if (_config != null) return _config!;
    
    _config = <String, String>{};
    
    try {
      final file = File('test_config.env');
      if (await file.exists()) {
        final lines = await file.readAsLines();
        
        for (final line in lines) {
          // Skip comments and empty lines
          if (line.trim().isEmpty || line.trim().startsWith('#')) {
            continue;
          }
          
          // Parse key=value pairs
          final parts = line.split('=');
          if (parts.length == 2) {
            final key = parts[0].trim();
            final value = parts[1].trim();
            _config![key] = value;
          }
        }
        
        print('✅ Loaded ${_config!.length} configuration values from test_config.env');
      } else {
        print('⚠️ test_config.env not found, using default values');
        _loadDefaults();
      }
    } catch (e) {
      print('⚠️ Error loading test_config.env: $e, using default values');
      _loadDefaults();
    }
    
    return _config!;
  }
  
  /// Load default configuration values
  static void _loadDefaults() {
    _config = {
      'TEST_EMAIL': 'silvester.vella@gmail.com',
      'TEST_PASSWORD': '12345678',
      'TEST_BASE_URL': 'http://localhost:3000',
      'TEST_RECALL_GAME_URL': 'http://localhost:3000/#/recall/lobby',
      'TEST_ACCOUNT_URL': 'http://localhost:3000/#/account',
      'APP_READY_TIMEOUT': '30',
      'LOGIN_TIMEOUT': '10',
      'NAVIGATION_TIMEOUT': '5',
      'SCREENSHOT_DIR': '.',
      'SCREENSHOT_PREFIX': 'test_',
    };
  }
  
  /// Get a configuration value
  static String get(String key, {String defaultValue = ''}) {
    return _config?[key] ?? defaultValue;
  }
  
  /// Get a configuration value as int
  static int getInt(String key, {int defaultValue = 0}) {
    final value = _config?[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }
  
  /// Get login credentials
  static String get testEmail => get('TEST_EMAIL', defaultValue: 'silvester.vella@gmail.com');
  static String get testPassword => get('TEST_PASSWORD', defaultValue: '12345678');
  
  /// Get test URLs
  static String get testBaseUrl => get('TEST_BASE_URL', defaultValue: 'http://localhost:3000');
  static String get testRecallGameUrl => get('TEST_RECALL_GAME_URL', defaultValue: 'http://localhost:3000/#/recall/lobby');
  static String get testAccountUrl => get('TEST_ACCOUNT_URL', defaultValue: 'http://localhost:3000/#/account');
  
  /// Get timeouts
  static int get appReadyTimeout => getInt('APP_READY_TIMEOUT', defaultValue: 30);
  static int get loginTimeout => getInt('LOGIN_TIMEOUT', defaultValue: 10);
  static int get navigationTimeout => getInt('NAVIGATION_TIMEOUT', defaultValue: 5);
  
  /// Get screenshot settings
  static String get screenshotDir => get('SCREENSHOT_DIR', defaultValue: '.');
  static String get screenshotPrefix => get('SCREENSHOT_PREFIX', defaultValue: 'test_');
} 