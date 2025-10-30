import 'package:flutter/foundation.dart';

/// Configuration class for API endpoints and settings
class ApiConfig {
  // Base URL for your PostgreSQL backend
  static const String _baseUrlDev = 'http://localhost:3000/api/v1';
  static const String _androidEmulatorBaseUrlDev = 'http://10.0.2.2:3000/api/v1';
  static const String _baseUrlProd = 'https://api.ptiplus.com/v1';
  // Allow overriding via --dart-define=API_BASE_URL
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  
  /// Get the appropriate base URL based on build mode
  static String get baseUrl {
    // If provided via env, always use it
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;

    if (!kDebugMode) return _baseUrlProd;

    // In debug: pick platform-aware dev base URL
    // Web and iOS simulators can use localhost directly
    // Android emulator needs 10.0.2.2 to reach host machine
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidEmulatorBaseUrlDev;
      default:
        return _baseUrlDev;
    }
  }
  
  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String vehiclesEndpoint = '/vehicles';
  static const String inspectionsEndpoint = '/inspections';
  static const String syncEndpoint = '/sync';
  
  // Authentication endpoints
  static const String loginEndpoint = '$authEndpoint/login';
  static const String refreshTokenEndpoint = '$authEndpoint/refresh';
  static const String logoutEndpoint = '$authEndpoint/logout';
  
  // Sync endpoints
  static const String syncUpEndpoint = '$syncEndpoint/up';
  static const String syncDownEndpoint = '$syncEndpoint/down';
  static const String syncStatusEndpoint = '$syncEndpoint/status';
  
  // Request timeouts (in milliseconds)
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  static const int sendTimeout = 60000; // 60 seconds
  
  // Retry configuration
  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 second
  
  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;
  
  // File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf'];
  
  /// Headers for API requests
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'X-Client-Platform': 'flutter',
    'X-Client-Version': '1.0.0',
  };
  
  /// Get authenticated headers with token
  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
  
  /// Database connection settings (for reference)
  static const Map<String, dynamic> dbConfig = {
    'host': 'db.ptiplus.com',
    'port': 5432,
    'database': 'pti_plus_db',
    'ssl': true,
    'pool_size': 20,
    'connection_timeout': 30,
  };
}