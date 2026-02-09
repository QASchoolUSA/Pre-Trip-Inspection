import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
import '../../core/services/simple_notification_service.dart';
// import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/firebase_service.dart';
// import '../../core/constants/localized_inspection_data.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/inspection_models.dart';


/// Core service providers
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

// Removed: apiServiceProvider

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

// Removed: databaseServiceProvider, syncServiceProvider, conflictResolutionServiceProvider, supabaseServiceProvider

/// Repository providers
final inspectionRepositoryProvider = Provider<InspectionRepository>((ref) {
  return InspectionRepository();
});

final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  return VehicleRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

// Removed: enhanced... providers

/// Current user provider
final currentUserProvider = StateProvider<User?>((ref) => null);

/// Selected vehicle provider
final selectedVehicleProvider = StateProvider<Vehicle?>((ref) => null);

/// Current inspection provider
final currentInspectionProvider = StateProvider<Inspection?>((ref) => null);

/// Inspections Notifier (Consolidated)
/// Uses InspectionRepository (Firestore)
final inspectionsProvider = StateNotifierProvider<InspectionsNotifier, List<Inspection>>((ref) {
  return InspectionsNotifier(ref.read(inspectionRepositoryProvider));
});

class InspectionsNotifier extends StateNotifier<List<Inspection>> {
  final InspectionRepository _repository;

  InspectionsNotifier(this._repository) : super([]) {
    loadInspections();
  }

  Future<void> loadInspections() async {
    try {
      final inspections = await _repository.fetchAllInspections();
      state = inspections;
    } catch (e) {
      print('Error loading inspections: $e');
      state = [];
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
    final inspection = await _repository.createInspection(
      context: context,
      driverId: driverId,
      driverName: driverName,
      vehicle: vehicle,
      type: type,
      location: location,
    );
    
    // Refresh list
    await loadInspections();
    return inspection;
  }

  Future<void> updateInspection(Inspection inspection) async {
    await _repository.updateInspection(inspection);
    await loadInspections();
  }

  Future<void> updateInspectionItem(String inspectionId, InspectionItem item) async {
    await _repository.updateInspectionItem(inspectionId, item);
    await loadInspections();
  }

  Future<void> completeInspection(String inspectionId, String signature, {String? notes}) async {
    await _repository.completeInspection(inspectionId, signature, overallNotes: notes);
    await loadInspections();
  }

  Future<void> deleteInspection(String id) async {
    await _repository.deleteInspection(id);
    await loadInspections();
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

  // Legacy compatibility: Sync status is always true/synced conceptually with Firestore offline persistence
  List<Inspection> getUnsyncedInspections() {
    return [];
  }

  Future<Map<String, dynamic>> getStats() async {
    // This is async now in repo, but we can compute from state if loaded
    return await _repository.getInspectionStats();
  }
}

// Alias enhancedInspectionsProvider to inspectionsProvider for backward compatibility
final enhancedInspectionsProvider = inspectionsProvider;

// IMPORTANT: We need a way to access the notifier of the 'enhanced' provider if existing code uses .notifier on it.
// StateNotifierProvider is complex to alias perfectly with .notifier access.
// Ideally code should migrate to inspectionsProvider.
// However, since I can't easily change all call sites in one go if they are widespread, 
// I will create a separate provider definition that reuses logic if possible or just directs to the same place.
// For now, let's assume most code uses ref.watch(enhancedInspectionsProvider).
// If code uses ref.read(enhancedInspectionsProvider.notifier), it will break with a simple Provider alias.
// So I will redefine enhancedInspectionsProvider as a StateNotifierProvider that effectively delegates or duplicates.
// Simpler approach: Just use the same Notifier class but a different instance/provider if needed, or point to same.
// Valid Alias:
final enhancedInspectionsProviderAlias = inspectionsProvider;

/// Vehicles Notifier (Consolidated)
final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, List<Vehicle>>((ref) {
  return VehiclesNotifier(ref.read(vehicleRepositoryProvider));
});

class VehiclesNotifier extends StateNotifier<List<Vehicle>> {
  final VehicleRepository _repository;

  VehiclesNotifier(this._repository) : super([]) {
    loadVehicles();
  }

  Future<void> syncFromServer() async {
    await loadVehicles();
  }

  Future<void> loadVehicles() async {
    try {
      final vehicles = await _repository.fetchAllVehicles();
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
    
    await loadVehicles();
    return vehicle;
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _repository.updateVehicle(vehicle);
    await loadVehicles();
  }

  Future<void> deleteVehicle(String id) async {
    await _repository.deleteVehicle(id);
    await loadVehicles(); 
  }

  List<Vehicle> getActiveVehicles() {
    return state.where((vehicle) => vehicle.isActive).toList();
  }

  // Async in repo, but filtering sync on state is fine for small datasets
  List<Vehicle> searchVehicles(String query) {
     final lowercaseQuery = query.toLowerCase();
     return state.where((vehicle) =>
            vehicle.unitNumber.toLowerCase().contains(lowercaseQuery) ||
            vehicle.make.toLowerCase().contains(lowercaseQuery) ||
            vehicle.model.toLowerCase().contains(lowercaseQuery) ||
            vehicle.plateNumber.toLowerCase().contains(lowercaseQuery) ||
            vehicle.vinNumber.toLowerCase().contains(lowercaseQuery) ||
            (vehicle.trailerNumber?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList();
  }

  List<Vehicle> getVehiclesDueForInspection() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return state.where((vehicle) =>
            vehicle.isActive &&
            (vehicle.lastInspectionDate == null ||
             vehicle.lastInspectionDate!.isBefore(thirtyDaysAgo)))
        .toList();
  }

  Future<Map<String, dynamic>> getStats() async {
    return await _repository.getVehicleStats();
  }
}

// Alias for compatibility
final enhancedVehiclesProvider = vehiclesProvider;

/// Users Notifier
final usersProvider = StateNotifierProvider<UsersNotifier, List<User>>((ref) {
  return UsersNotifier(ref.read(userRepositoryProvider));
});

class UsersNotifier extends StateNotifier<List<User>> {
  final UserRepository _repository;

  UsersNotifier(this._repository) : super([]) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    final users = await _repository.fetchUsers();
    state = users;
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
    
    await loadUsers();
    return user;
  }

  Future<void> updateUser(User user) async {
    await _repository.updateUser(user);
    await loadUsers();
  }

  Future<void> updateLastLogin(String id) async {
    await _repository.updateLastLogin(id);
    await loadUsers();
  }

  Future<void> deleteUser(String id) async {
    await _repository.deleteUser(id);
    await loadUsers();
  }

  List<User> getActiveUsers() {
    return state.where((user) => user.isActive).toList();
  }

  List<User> searchUsers(String query) {
     final lowercaseQuery = query.toLowerCase();
     return state.where((user) =>
            user.name.toLowerCase().contains(lowercaseQuery) ||
            user.cdlNumber.toLowerCase().contains(lowercaseQuery) ||
            (user.email?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList();
  }

  List<User> getUsersWithExpiringDocuments() {
    return state.where((user) => 
            user.isActive && 
            (user.isCdlExpiringSoon || user.isMedicalCertExpiringSoon))
        .toList();
  }

  User? getUserByCdlNumber(String cdlNumber) {
    return state.where((user) => user.cdlNumber == cdlNumber).firstOrNull;
  }

  Future<Map<String, dynamic>> getStats() async {
    return await _repository.getUserStats();
  }
}

/// Authentication status provider
final authStatusProvider = StateProvider<bool>((ref) => false);

/// App initialization provider
final appInitializationProvider = FutureProvider<bool>((ref) async {
  try {
    // Initialize Firebase
    await FirebaseService.instance.initialize();
    // ApiService is removed
    await AuthService.instance.initialize();

    // Check authentication status
    final isAuthenticated = await AuthService.instance.isAuthenticated();
    ref.read(authStatusProvider.notifier).state = isAuthenticated;
    
    // Load initial data
    // Note: Since notifiers call load in constructor, reading them triggers load
    ref.read(inspectionsProvider);
    ref.read(vehiclesProvider);
    ref.read(usersProvider);
    
    // Get current user if authenticated
    if (isAuthenticated) {
      final userData = await AuthService.instance.getUserData();
      if (userData != null) {
        ref.read(currentUserProvider.notifier).state = User.fromJson(userData);
      }
    }
    
    return true;
  } catch (e) {
    throw Exception('Failed to initialize app: $e');
  }
});

// Alias for enhanced init
final enhancedAppInitializationProvider = appInitializationProvider;

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