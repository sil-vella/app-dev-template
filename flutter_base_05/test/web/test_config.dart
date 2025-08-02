// Test configuration for web testing
class TestConfig {
  // List of test files to run in order
  static const List<String> testFiles = [
    'single_web_test.dart',      // Basic app functionality
    'recall_game_test.dart',     // Recall game screen
    // Add more test files here as needed:
    // 'auth_test.dart',         // Authentication flow
    // 'profile_test.dart',      // User profile screen
    // 'settings_test.dart',     // Settings screen
    // 'leaderboard_test.dart',  // Leaderboard screen
  ];
  
  // Test descriptions for better logging
  static const Map<String, String> testDescriptions = {
    'single_web_test.dart': 'Basic app functionality',
    'recall_game_test.dart': 'Recall game screen',
    // Add descriptions for new tests here
  };
  
  // Get test description
  static String getTestDescription(String testFile) {
    return testDescriptions[testFile] ?? 'Unknown test';
  }
  
  // Check if test file exists
  static bool testFileExists(String testFile) {
    // This would be implemented to check if the file exists
    return testFiles.contains(testFile);
  }
} 