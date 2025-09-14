/// Application constants for PTI Mobile App
class AppConstants {
  static const String appName = 'PTI Mobile';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Pre-Trip Inspection Progressive Web App';
  
  // Database constants
  static const String hiveBoxName = 'pti_box';
  static const String inspectionsBoxName = 'inspections_box';
  static const String vehiclesBoxName = 'vehicles_box';
  static const String usersBoxName = 'users_box';
  
  // SharedPreferences keys
  static const String userPinKey = 'user_pin';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String languageKey = 'selected_language';
  static const String themeKey = 'theme_mode';
  static const String lastSyncKey = 'last_sync_timestamp';
  
  // API endpoints (for future implementation)
  static const String baseUrl = 'https://api.ptimobile.com/v1';
  static const String syncEndpoint = '/sync';
  static const String uploadEndpoint = '/upload';
  
  // Inspection categories
  static const List<String> inspectionCategories = [
    'Power Unit',
    'Trailer',
    'Safety Equipment',
    'Documentation',
  ];
  
  // Defect severity levels
  static const List<String> defectSeverityLevels = [
    'Minor',
    'Major',
    'Critical',
    'Out of Service',
  ];
  
  // Maximum file sizes
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxPdfSizeBytes = 10 * 1024 * 1024; // 10MB
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 48.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 48.0;
  
  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // Offline sync settings
  static const Duration syncRetryInterval = Duration(minutes: 5);
  static const int maxSyncRetries = 3;
  
  // Camera settings
  static const double imageQuality = 0.8;
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;
}

/// Route names for navigation
class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String vehicleSelection = '/vehicle-selection';
  static const String inspection = '/inspection';
  static const String inspectionDetails = '/inspection/:id';
  static const String defectReporting = '/defect-reporting';
  static const String signature = '/signature';
  static const String reportPreview = '/report-preview';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String offlineSync = '/offline-sync';
}

/// Error messages
class ErrorMessages {
  static const String networkError = 'No internet connection. Working offline.';
  static const String syncError = 'Failed to sync data. Will retry later.';
  static const String cameraError = 'Camera not available.';
  static const String locationError = 'Location services not available.';
  static const String storageError = 'Storage not available.';
  static const String invalidPin = 'Invalid PIN. Please try again.';
  static const String inspectionIncomplete = 'Please complete all required items.';
  static const String signatureRequired = 'Digital signature is required.';
  static const String reportGenerationError = 'Failed to generate report.';
}

/// Success messages
class SuccessMessages {
  static const String inspectionSaved = 'Inspection saved successfully.';
  static const String reportGenerated = 'Report generated successfully.';
  static const String dataSynced = 'Data synchronized successfully.';
  static const String settingsUpdated = 'Settings updated successfully.';
}