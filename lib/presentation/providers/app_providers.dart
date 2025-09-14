import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/simple_notification_service.dart';
import '../../data/datasources/database_service.dart';
import '../../data/repositories/inspection_repository.dart';
import '../../data/repositories/vehicle_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/inspection_models.dart';

/// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

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

/// Current user provider
final currentUserProvider = StateProvider<User?>((ref) => null);

/// Selected vehicle provider
final selectedVehicleProvider = StateProvider<Vehicle?>((ref) => null);

/// Current inspection provider
final currentInspectionProvider = StateProvider<Inspection?>((ref) => null);

/// All inspections provider
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
    required String driverId,
    required String driverName,
    required Vehicle vehicle,
    required InspectionType type,
    LocationInfo? location,
  }) async {
    final inspection = await _repository.createInspection(
      driverId: driverId,
      driverName: driverName,
      vehicle: vehicle,
      type: type,
      location: location,
    );
    
    loadInspections(); // Refresh the list
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

/// All vehicles provider
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
    state = _repository.getAllVehicles();
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

/// App initialization provider
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