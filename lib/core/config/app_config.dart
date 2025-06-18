/// Application configuration class
/// Centralizes all configuration settings for easy maintenance
class AppConfig {
  // API Configuration
  static const String defaultApiBaseUrl = 'https://vogu-health-be.onrender.com';
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // Data Configuration
  static const int defaultDataDays = 7;
  static const int maxDataDays = 30;
  static const int minDataDays = 1;
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  // UI Configuration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  
  // Validation Configuration
  static const int minHeartRate = 40;
  static const int maxHeartRate = 200;
  static const double minWeight = 20.0;
  static const double maxWeight = 300.0;
  static const int minSleepQuality = 0;
  static const int maxSleepQuality = 100;
  
  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableAnalytics = false;
  static const bool enableDebugLogging = true;
  
  // Offline Mode Configuration
  static const Duration syncInterval = Duration(minutes: 15);
  static const int maxSyncRetries = 3;
  static const Duration syncRetryDelay = Duration(minutes: 5);
  static const Duration dataRetentionPeriod = Duration(days: 30);
  
  // Environment-specific configuration
  static String get apiBaseUrl {
    const env = String.fromEnvironment('API_BASE_URL');
    return env.isNotEmpty ? env : defaultApiBaseUrl;
  }
  
  static bool get isProduction {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    return env == 'production';
  }
  
  static bool get isDebug {
    const env = String.fromEnvironment('FLUTTER_DEBUG', defaultValue: 'true');
    return env == 'true';
  }
  
  // Validation methods
  static bool isValidHeartRate(int value) {
    return value >= minHeartRate && value <= maxHeartRate;
  }
  
  static bool isValidWeight(double value) {
    return value >= minWeight && value <= maxWeight;
  }
  
  static bool isValidSleepQuality(int value) {
    return value >= minSleepQuality && value <= maxSleepQuality;
  }
  
  static bool isValidDataDays(int days) {
    return days >= minDataDays && days <= maxDataDays;
  }
} 