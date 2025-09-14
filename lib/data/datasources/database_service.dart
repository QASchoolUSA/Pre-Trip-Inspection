import 'package:hive_flutter/hive_flutter.dart';
import '../models/inspection_models.dart';
import '../../core/constants/app_constants.dart';

/// Service for managing local database operations using Hive
class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  DatabaseService._();

  bool _isInitialized = false;

  /// Initialize the database
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Register Hive adapters
    _registerAdapters();

    // Open boxes
    await _openBoxes();

    _isInitialized = true;
  }

  /// Register all Hive type adapters
  void _registerAdapters() {
    // Register enum adapters
    Hive.registerAdapter(InspectionStatusAdapter());
    Hive.registerAdapter(InspectionTypeAdapter());
    Hive.registerAdapter(DefectSeverityAdapter());
    Hive.registerAdapter(InspectionItemStatusAdapter());

    // Register model adapters
    Hive.registerAdapter(InspectionItemAdapter());
    Hive.registerAdapter(VehicleAdapter());
    Hive.registerAdapter(LocationInfoAdapter());
    Hive.registerAdapter(InspectionAdapter());
    Hive.registerAdapter(UserAdapter());
  }

  /// Open all required Hive boxes
  Future<void> _openBoxes() async {
    await Future.wait([
      Hive.openBox<Inspection>(AppConstants.inspectionsBoxName),
      Hive.openBox<Vehicle>(AppConstants.vehiclesBoxName),
      Hive.openBox<User>(AppConstants.usersBoxName),
      Hive.openBox(AppConstants.hiveBoxName), // General box for settings
    ]);
  }

  /// Get inspections box
  Box<Inspection> get inspectionsBox =>
      Hive.box<Inspection>(AppConstants.inspectionsBoxName);

  /// Get vehicles box
  Box<Vehicle> get vehiclesBox =>
      Hive.box<Vehicle>(AppConstants.vehiclesBoxName);

  /// Get users box
  Box<User> get usersBox =>
      Hive.box<User>(AppConstants.usersBoxName);

  /// Get general settings box
  Box get settingsBox =>
      Hive.box(AppConstants.hiveBoxName);

  /// Close all boxes and clean up
  Future<void> dispose() async {
    await Hive.close();
    _isInitialized = false;
  }

  /// Clear all data (for testing or reset)
  Future<void> clearAllData() async {
    await Future.wait([
      inspectionsBox.clear(),
      vehiclesBox.clear(),
      usersBox.clear(),
      settingsBox.clear(),
    ]);
  }

  /// Get database size information
  Future<Map<String, int>> getDatabaseStats() async {
    return {
      'inspections': inspectionsBox.length,
      'vehicles': vehiclesBox.length,
      'users': usersBox.length,
      'settings': settingsBox.length,
    };
  }

  /// Compact database to reclaim space
  Future<void> compactDatabase() async {
    await Future.wait([
      inspectionsBox.compact(),
      vehiclesBox.compact(),
      usersBox.compact(),
      settingsBox.compact(),
    ]);
  }

  /// Export database for backup
  Future<Map<String, dynamic>> exportDatabase() async {
    return {
      'inspections': inspectionsBox.values
          .map((inspection) => inspection.toJson())
          .toList(),
      'vehicles': vehiclesBox.values
          .map((vehicle) => vehicle.toJson())
          .toList(),
      'users': usersBox.values
          .map((user) => user.toJson())
          .toList(),
      'settings': Map<String, dynamic>.from(settingsBox.toMap()),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import database from backup
  Future<void> importDatabase(Map<String, dynamic> backup) async {
    try {
      // Clear existing data
      await clearAllData();

      // Import inspections
      if (backup['inspections'] != null) {
        final inspections = (backup['inspections'] as List)
            .map((json) => Inspection.fromJson(json))
            .toList();
        
        for (final inspection in inspections) {
          await inspectionsBox.put(inspection.id, inspection);
        }
      }

      // Import vehicles
      if (backup['vehicles'] != null) {
        final vehicles = (backup['vehicles'] as List)
            .map((json) => Vehicle.fromJson(json))
            .toList();
        
        for (final vehicle in vehicles) {
          await vehiclesBox.put(vehicle.id, vehicle);
        }
      }

      // Import users
      if (backup['users'] != null) {
        final users = (backup['users'] as List)
            .map((json) => User.fromJson(json))
            .toList();
        
        for (final user in users) {
          await usersBox.put(user.id, user);
        }
      }

      // Import settings
      if (backup['settings'] != null) {
        final settings = backup['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          await settingsBox.put(entry.key, entry.value);
        }
      }
    } catch (e) {
      throw Exception('Failed to import database: $e');
    }
  }
}