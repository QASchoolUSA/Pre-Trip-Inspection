import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../core/services/simple_notification_service.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/services/conflict_resolution_service.dart';
import '../../core/constants/localized_inspection_data.dart';
import '../../data/datasources/database_service.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/repositories/enhanced_inspection_repository.dart';
import '../../data/repositories/enhanced_vehicle_repository.dart';
import '../../data/models/inspection_models.dart';
import '../../data/models/sync_models.dart';

/// Core service providers
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService.instance;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService.instance;
});

final conflictResolutionServiceProvider = Provider<ConflictResolutionService>((ref) {
  return ConflictResolutionService.instance;
});

/// Legacy repository providers (for backward compatibility)
final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  return InspectionRepository();
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Enhanced repository providers with PostgreSQL sync
final enhancedInspectionRepositoryProvider = Provider<EnhancedInspectionRepository>((ref) {
  return EnhancedInspectionRepository.instance;
});

final enhancedVehicleRepositoryProvider = Provider<EnhancedVehicleRepository>((ref) {
  return EnhancedVehicleRepository.instance;
});

/// Current user provider
final currentUserProvider = StateProvider<User?>((ref) => null);

/// Selected vehicle provider
final selectedVehicleProvider = StateProvider<Vehicle?>((ref) => null);

/// Current inspection provider
final currentInspectionProvider = StateProvider<Inspection?>((ref) => null);

/// Enhanced inspections provider with PostgreSQL sync
final enhancedInspectionsProvider = StateNotifierProvider<EnhancedInspectionsNotifier, List<Inspection>>((ref) {
  return EnhancedInspectionsNotifier(ref.read(enhancedInspectionRepositoryProvider));
});

/// Enhanced inspections state notifier
class EnhancedInspectionsNotifier extends StateNotifier<List<Inspection>> {
  final EnhancedInspectionRepository _repository;

  EnhancedInspectionsNotifier(this._repository) : super([]) {
    loadInspections();
  }

  Future<void> loadInspections() async {
    try {
      final inspections = await _repository.getAllInspections();
      state = inspections;
    } catch (e) {
      rethrow;
    }
  }

  Future<Inspection> createInspection({
    required BuildContext context,
    required String driverId,
    required String driverName,
    required Vehicle vehicle,
    required InspectionType type,
    LocationInfo? location,
  }) async {
    // Create an Inspection object to pass to the repository
    final inspection = Inspection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicle: vehicle,
      driverId: driverId,
      driverName: driverName,
      type: type,
      status: InspectionStatus.inProgress,
      items: LocalizedInspectionData.getAllInspectionItems(context),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
      version: 1,
      location: location,
      isSynced: false,
      isDeleted: false,
      pendingOperations: [],
    );
    
    final createdInspection = await _repository.createInspection(inspection);
    
    loadInspections(); // Refresh the list
    return createdInspection;
  }

  Future<void> updateInspection(Inspection inspection) async {
    await _repository.updateInspection(inspection);
    loadInspections(); // Refresh the list
  }

  Future<void> updateInspectionItem(String inspectionId, InspectionItem updatedItem) async {
    try {
      await _repository.updateInspectionItem(inspectionId, updatedItem);
      await loadInspections();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> completeInspection(String inspectionId, String signature, {String? notes}) async {
    await _repository.completeInspection(inspectionId, signature, overallNotes: notes);
    loadInspections(); // Refresh the list
  }

  Future<void> deleteInspection(String id) async {
    await _repository.deleteInspection(id);
    loadInspections(); // Refresh the list
  }

  List<Inspection> getInspectionsByStatus(InspectionStatus status) {
    return state.where((inspection) => inspection.status == status).toList();
  }

  List<Inspection> getInspectionsByDriver(String driverId) {
    return state.where((inspection) => inspection.driverId == driverId).toList();
  }

  List<Inspection> getInspectionsByVehicle(String vehicleId) {
    return state.where((inspection) => inspection.vehicle.id == vehicleId).toList();
  }

  List<Inspection> getInspectionsByDateRange(DateTime start, DateTime end) {
    return state.where((inspection) => 
      inspection.createdAt.isAfter(start) && 
      inspection.createdAt.isBefore(end)
    ).toList();
  }

  List<Inspection> getUnsyncedInspections() {
    return state.where((inspection) => inspection.syncStatus != SyncStatus.synced).toList();
  }

  Future<void> syncFromServer() async {
    try {
      await _repository.syncFromServer();
      loadInspections(); // Refresh after sync
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    return await _repository.getInspectionStats();
  }
}

/// All inspections provider (legacy)
final inspectionsProvider = StateNotifierProvider<InspectionsNotifier, List<Inspection>>((ref) {
  return InspectionsNotifier(ref.read(inspectionRepositoryProvider));
});

/// Inspections state notifier
class InspectionsNotifier extends StateNotifier<List<Inspection>> {
  final InspectionRepository _repository;

  InspectionsNotifier(this._repository) : super([]) {
    loadInspections();
  }

  void loadInspections() {
    state = _repository.getAllInspections();
  }

  Future<Inspection> createInspection({
    required BuildContext context,
    required String driverId,
    required String driverName,
    required Vehicle vehicle,
    required InspectionType type,
    LocationInfo? location,
  }) async {
    final inspection = await _repository.createInspection(
      context: context,
      driverId: driverId,
      driverName: driverName,
      vehicle: vehicle,
      type: type,
      location: location,
    );
    
    // Refresh the list and ensure the new inspection is in the state
    loadInspections();
    
    // Add a small delay to ensure state propagation
    await Future.delayed(const Duration(milliseconds: 50));
    
    return inspection;
  }

  Future<void> updateInspection(Inspection inspection) async {
    await _repository.updateInspection(inspection);
    loadInspections(); // Refresh the list
  }

  Future<void> updateInspectionItem(String inspectionId, InspectionItem item) async {
    await _repository.updateInspectionItem(inspectionId, item);
    loadInspections(); // Refresh the list
  }

  Future<void> completeInspection(String inspectionId, String signature, {String? notes}) async {
    await _repository.completeInspection(inspectionId, signature, overallNotes: notes);
    loadInspections(); // Refresh the list
  }

  Future<void> deleteInspection(String id) async {
    await _repository.deleteInspection(id);
    loadInspections(); // Refresh the list
  }

  List<Inspection> getInspectionsByStatus(InspectionStatus status) {
    return state.where((inspection) => inspection.status == status).toList();
  }

  List<Inspection> getUnsyncedInspections() {
    return state.where((inspection) => !inspection.isSynced).toList();
  }

  Map<String, dynamic> getStats() {
    return _repository.getInspectionStats();
  }
}

/// Enhanced vehicles provider with PostgreSQL sync
final enhancedVehiclesProvider = StateNotifierProvider<EnhancedVehiclesNotifier, List<Vehicle>>((ref) {
  return EnhancedVehiclesNotifier(ref.read(enhancedVehicleRepositoryProvider));
});

/// Enhanced vehicles state notifier
class EnhancedVehiclesNotifier extends StateNotifier<List<Vehicle>> {
  final EnhancedVehicleRepository _repository;

  EnhancedVehiclesNotifier(this._repository) : super([]) {
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    try {
      final vehicles = _repository.getAllVehicles();
      state = vehicles;
    } catch (e) {
      state = [];
    }
  }

  Future<Vehicle> createVehicle({
    required String unitNumber,
    required String make,
    required String model,
    required int year,
    required String vinNumber,
    required String plateNumber,
    String? trailerNumber,
    double? mileage,
  }) async {
    // Create a Vehicle object to pass to the repository
    final vehicle = Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      unitNumber: unitNumber,
      make: make,
      model: model,
      year: year,
      vinNumber: vinNumber,
      plateNumber: plateNumber,
      trailerNumber: trailerNumber,
      mileage: mileage ?? 0.0,
      isActive: true,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
      version: 1,
      pendingOperations: [],
    );
    
    final createdVehicle = await _repository.createVehicle(vehicle);
    
    loadVehicles(); // Refresh the list
    return createdVehicle;
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _repository.updateVehicle(vehicle);
    loadVehicles(); // Refresh the list
  }

  Future<void> deleteVehicle(String id) async {
    await _repository.deleteVehicle(id);
    loadVehicles(); // Refresh the list
  }

  List<Vehicle> getActiveVehicles() {
    return state.where((vehicle) => vehicle.isActive).toList();
  }

  Future<List<Vehicle>> searchVehicles(String query) async {
    return await _repository.searchVehicles(query: query);
  }

  Future<List<Vehicle>> getVehiclesDueForInspection() async {
    return await _repository.getVehiclesDueForInspection();
  }

  List<Vehicle> getUnsyncedVehicles() {
    return state.where((vehicle) => vehicle.syncStatus != SyncStatus.synced).toList();
  }

  Future<void> syncFromServer() async {
    try {
      await _repository.syncFromServer();
      loadVehicles(); // Refresh after sync
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStats() async {
    return await _repository.getVehicleStats();
  }
}

/// All vehicles provider (legacy)
final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, List<Vehicle>>((ref) {
  return VehiclesNotifier(ref.read(vehicleRepositoryProvider));
});

/// Vehicles state notifier
class VehiclesNotifier extends StateNotifier<List<Vehicle>> {
  final VehicleRepository _repository;

  VehiclesNotifier(this._repository) : super([]) {
    loadVehicles();
  }

  void loadVehicles() {
    try {
      final vehicles = _repository.getAllVehicles();
      state = vehicles;
    } catch (e) {
      state = [];
    }
  }

  Future<Vehicle> createVehicle({
    required String unitNumber,
    required String make,
    required String model,
    required int year,
    required String vinNumber,
    required String plateNumber,
    String? trailerNumber,
    double? mileage,
  }) async {
    final vehicle = await _repository.createVehicle(
      unitNumber: unitNumber,
      make: make,
      model: model,
      year: year,
      vinNumber: vinNumber,
      plateNumber: plateNumber,
      trailerNumber: trailerNumber,
      mileage: mileage,
    );
    
    loadVehicles(); // Refresh the list
    return vehicle;
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _repository.updateVehicle(vehicle);
    loadVehicles(); // Refresh the list
  }

  Future<void> deleteVehicle(String id) async {
    await _repository.deleteVehicle(id);
    loadVehicles(); // Refresh the list
  }

  List<Vehicle> getActiveVehicles() {
    return state.where((vehicle) => vehicle.isActive).toList();
  }

  List<Vehicle> searchVehicles(String query) {
    return _repository.searchVehicles(query);
  }

  List<Vehicle> getVehiclesDueForInspection() {
    return _repository.getVehiclesDueForInspection();
  }

  Map<String, dynamic> getStats() {
    return _repository.getVehicleStats();
  }
}

/// All users provider
final usersProvider = StateNotifierProvider<UsersNotifier, List<User>>((ref) {
  return UsersNotifier(ref.read(userRepositoryProvider));
});

/// Users state notifier
class UsersNotifier extends StateNotifier<List<User>> {
  final UserRepository _repository;

  UsersNotifier(this._repository) : super([]) {
    loadUsers();
  }

  void loadUsers() {
    state = _repository.getAllUsers();
  }

  Future<User> createUser({
    required String name,
    required String cdlNumber,
    DateTime? cdlExpiryDate,
    DateTime? medicalCertExpiryDate,
    String? phoneNumber,
    String? email,
  }) async {
    final user = await _repository.createUser(
      name: name,
      cdlNumber: cdlNumber,
      cdlExpiryDate: cdlExpiryDate,
      medicalCertExpiryDate: medicalCertExpiryDate,
      phoneNumber: phoneNumber,
      email: email,
    );
    
    loadUsers(); // Refresh the list
    return user;
  }

  Future<void> updateUser(User user) async {
    await _repository.updateUser(user);
    loadUsers(); // Refresh the list
  }

  Future<void> updateLastLogin(String id) async {
    await _repository.updateLastLogin(id);
    loadUsers(); // Refresh the list
  }

  Future<void> deleteUser(String id) async {
    await _repository.deleteUser(id);
    loadUsers(); // Refresh the list
  }

  List<User> getActiveUsers() {
    return state.where((user) => user.isActive).toList();
  }

  List<User> searchUsers(String query) {
    return _repository.searchUsers(query);
  }

  List<User> getUsersWithExpiringDocuments() {
    return _repository.getUsersWithExpiringDocuments();
  }

  User? getUserByCdlNumber(String cdlNumber) {
    return _repository.getUserByCdlNumber(cdlNumber);
  }

  Map<String, dynamic> getStats() {
    return _repository.getUserStats();
  }
}

/// Sync status provider
final syncStatusProvider = StreamProvider<SyncStats>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return syncService.syncStatsStream;
});

/// Sync batch provider
final syncBatchProvider = StreamProvider<SyncBatch>((ref) {
  final syncService = ref.read(syncServiceProvider);
  return syncService.syncBatchStream;
});

/// Authentication status provider
final authStatusProvider = StateProvider<bool>((ref) => false);

/// Enhanced app initialization provider with PostgreSQL sync
final enhancedAppInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    // Initialize core services
    await DatabaseService.instance.initialize();
    await ApiService.instance.initialize();
    await AuthService.instance.initialize();
    await SyncService.instance.initialize();
    
    // Check authentication status
    final isAuthenticated = await AuthService.instance.isAuthenticated();
    ref.read(authStatusProvider.notifier).state = isAuthenticated;
    
    // Load initial data using enhanced repositories
    ref.read(enhancedInspectionsProvider.notifier).loadInspections();
    ref.read(enhancedVehiclesProvider.notifier).loadVehicles();
    ref.read(usersProvider.notifier).loadUsers();
    
    // Start sync if authenticated
    if (isAuthenticated) {
      SyncService.instance.startPeriodicSync();
    }
    
    return true;
  } catch (e) {
    throw Exception('Failed to initialize app with PostgreSQL sync: $e');
  }
});

/// App initialization provider (legacy)
final appInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    // Initialize database
    await DatabaseService.instance.initialize();
    
    // Load initial data
    ref.read(inspectionsProvider.notifier).loadInspections();
    ref.read(vehiclesProvider.notifier).loadVehicles();
    ref.read(usersProvider.notifier).loadUsers();
    
    return true;
  } catch (e) {
    throw Exception('Failed to initialize app: $e');
  }
});

/// Network connectivity provider
final connectivityProvider = StateProvider<bool>((ref) => true);

/// Theme mode provider
final themeModeProvider = StateProvider<bool>((ref) => false); // false = light, true = dark

/// Language provider
final languageProvider = StateProvider<String>((ref) => 'en');

/// Loading state providers
final isLoadingProvider = StateProvider<bool>((ref) => false);
final loadingMessageProvider = StateProvider<String?>((ref) => null);

/// Error state provider
final errorProvider = StateProvider<String?>((ref) => null);

/// Success message provider
final successMessageProvider = StateProvider<String?>((ref) => null);

/// Notification service provider
final notificationServiceProvider = Provider<SimpleNotificationService>((ref) {
  return SimpleNotificationService();
});