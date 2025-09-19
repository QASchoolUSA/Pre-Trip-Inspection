import '../models/inspection_models.dart';
import '../datasources/database_service.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing vehicle data
class VehicleRepository {
  final DatabaseService _db = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  /// Get all vehicles
  List<Vehicle> getAllVehicles() {
    final vehicles = _db.vehiclesBox.values.toList()
      ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
    print('DEBUG: VehicleRepository.getAllVehicles() - Found ${vehicles.length} vehicles in database');
    return vehicles;
  }

  /// Get active vehicles
  List<Vehicle> getActiveVehicles() {
    return _db.vehiclesBox.values
        .where((vehicle) => vehicle.isActive)
        .toList()
      ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
  }

  /// Get vehicle by ID
  Vehicle? getVehicleById(String id) {
    return _db.vehiclesBox.get(id);
  }

  /// Get vehicle by unit number
  Vehicle? getVehicleByUnitNumber(String unitNumber) {
    return _db.vehiclesBox.values
        .where((vehicle) => vehicle.unitNumber == unitNumber)
        .firstOrNull;
  }

  /// Create new vehicle
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
    final vehicle = Vehicle(
      id: _uuid.v4(),
      unitNumber: unitNumber,
      make: make,
      model: model,
      year: year,
      vinNumber: vinNumber,
      plateNumber: plateNumber,
      trailerNumber: trailerNumber,
      mileage: mileage,
    );

    await _db.vehiclesBox.put(vehicle.id, vehicle);
    return vehicle;
  }

  /// Update vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    await _db.vehiclesBox.put(vehicle.id, vehicle);
  }

  /// Update vehicle mileage
  Future<void> updateVehicleMileage(String id, double mileage) async {
    final vehicle = getVehicleById(id);
    if (vehicle == null) return;

    final updatedVehicle = vehicle.copyWith(mileage: mileage);
    await updateVehicle(updatedVehicle);
  }

  /// Update last inspection date
  Future<void> updateLastInspectionDate(String id, DateTime date) async {
    final vehicle = getVehicleById(id);
    if (vehicle == null) return;

    final updatedVehicle = vehicle.copyWith(lastInspectionDate: date);
    await updateVehicle(updatedVehicle);
  }

  /// Deactivate vehicle
  Future<void> deactivateVehicle(String id) async {
    final vehicle = getVehicleById(id);
    if (vehicle == null) return;

    final deactivatedVehicle = vehicle.copyWith(isActive: false);
    await updateVehicle(deactivatedVehicle);
  }

  /// Activate vehicle
  Future<void> activateVehicle(String id) async {
    final vehicle = getVehicleById(id);
    if (vehicle == null) return;

    final activatedVehicle = vehicle.copyWith(isActive: true);
    await updateVehicle(activatedVehicle);
  }

  /// Delete vehicle
  Future<void> deleteVehicle(String id) async {
    await _db.vehiclesBox.delete(id);
  }

  /// Search vehicles by various criteria
  List<Vehicle> searchVehicles(String query) {
    final lowercaseQuery = query.toLowerCase();
    
    return _db.vehiclesBox.values
        .where((vehicle) =>
            vehicle.unitNumber.toLowerCase().contains(lowercaseQuery) ||
            vehicle.make.toLowerCase().contains(lowercaseQuery) ||
            vehicle.model.toLowerCase().contains(lowercaseQuery) ||
            vehicle.plateNumber.toLowerCase().contains(lowercaseQuery) ||
            vehicle.vinNumber.toLowerCase().contains(lowercaseQuery) ||
            (vehicle.trailerNumber?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList()
      ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
  }

  /// Get vehicles due for inspection (over 30 days since last inspection)
  List<Vehicle> getVehiclesDueForInspection() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    return _db.vehiclesBox.values
        .where((vehicle) =>
            vehicle.isActive &&
            (vehicle.lastInspectionDate == null ||
             vehicle.lastInspectionDate!.isBefore(thirtyDaysAgo)))
        .toList()
      ..sort((a, b) => a.unitNumber.compareTo(b.unitNumber));
  }

  /// Get vehicle statistics
  Map<String, dynamic> getVehicleStats() {
    final vehicles = getAllVehicles();
    final activeVehicles = getActiveVehicles();
    final dueForInspection = getVehiclesDueForInspection();

    return {
      'total': vehicles.length,
      'active': activeVehicles.length,
      'inactive': vehicles.length - activeVehicles.length,
      'dueForInspection': dueForInspection.length,
      'byMake': _groupVehiclesByMake(activeVehicles),
      'byYear': _groupVehiclesByYear(activeVehicles),
    };
  }

  /// Group vehicles by make
  Map<String, int> _groupVehiclesByMake(List<Vehicle> vehicles) {
    final Map<String, int> makeCount = {};
    
    for (final vehicle in vehicles) {
      makeCount[vehicle.make] = (makeCount[vehicle.make] ?? 0) + 1;
    }
    
    return makeCount;
  }

  /// Group vehicles by year
  Map<String, int> _groupVehiclesByYear(List<Vehicle> vehicles) {
    final Map<String, int> yearCount = {};
    
    for (final vehicle in vehicles) {
      final yearRange = _getYearRange(vehicle.year);
      yearCount[yearRange] = (yearCount[yearRange] ?? 0) + 1;
    }
    
    return yearCount;
  }

  /// Get year range for grouping (e.g., "2020-2024", "2015-2019")
  String _getYearRange(int year) {
    final currentYear = DateTime.now().year;
    
    if (year >= currentYear - 4) {
      return '${currentYear - 4}-$currentYear';
    } else if (year >= currentYear - 9) {
      return '${currentYear - 9}-${currentYear - 5}';
    } else if (year >= currentYear - 14) {
      return '${currentYear - 14}-${currentYear - 10}';
    } else {
      return 'Older than ${currentYear - 15}';
    }
  }

  /// Add sample vehicles for development/testing
  Future<void> addSampleVehicles() async {
    print('DEBUG: addSampleVehicles() called');
    final sampleVehicles = [
      Vehicle(
        id: _uuid.v4(),
        unitNumber: 'T001',
        make: 'Freightliner',
        model: 'Cascadia',
        year: 2022,
        vinNumber: '1FUJGBDV2NLKA1234',
        plateNumber: 'ABC123',
        mileage: 125000,
      ),
      Vehicle(
        id: _uuid.v4(),
        unitNumber: 'T002',
        make: 'Peterbilt',
        model: '579',
        year: 2021,
        vinNumber: '1XPBDP9X4MD123456',
        plateNumber: 'DEF456',
        trailerNumber: 'TR001',
        mileage: 98000,
      ),
      Vehicle(
        id: _uuid.v4(),
        unitNumber: 'T003',
        make: 'Kenworth',
        model: 'T680',
        year: 2023,
        vinNumber: '1XKYDP9X1NJ789012',
        plateNumber: 'GHI789',
        mileage: 75000,
      ),
    ];

    print('DEBUG: Adding ${sampleVehicles.length} sample vehicles to database');
    for (final vehicle in sampleVehicles) {
      await _db.vehiclesBox.put(vehicle.id, vehicle);
      print('DEBUG: Added vehicle ${vehicle.unitNumber} to database');
    }
    print('DEBUG: Sample vehicles added successfully');
  }
}