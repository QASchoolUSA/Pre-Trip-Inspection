import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/firebase_service.dart';
import '../models/inspection_models.dart';

/// Repository for managing vehicle data using Firestore
class VehicleRepository {
  final FirebaseService _firebase = FirebaseService.instance;
  final Uuid _uuid = const Uuid();
  
  CollectionReference<Map<String, dynamic>> get _vehiclesCollection => 
      _firebase.collection('vehicles');

  /// Get all vehicles
  /// Note: Returns empty list synchronously. Use fetchAllVehicles for async.
  List<Vehicle> getAllVehicles() {
    return [];
  }
  
  /// Fetch all vehicles from Firestore
  Future<List<Vehicle>> fetchAllVehicles() async {
    try {
      final snapshot = await _vehiclesCollection
        .orderBy('unit_number')
        .get();
      return snapshot.docs.map((doc) => Vehicle.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching vehicles: $e');
      return [];
    }
  }

  /// Get active vehicles
  Future<List<Vehicle>> getActiveVehicles() async {
    try {
      final snapshot = await _vehiclesCollection
          .where('is_active', isEqualTo: true)
          .orderBy('unit_number')
          .get();
      return snapshot.docs.map((doc) => Vehicle.fromJson(doc.data())).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get vehicle by ID
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      final doc = await _vehiclesCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Vehicle.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get vehicle by unit number
  Future<Vehicle?> getVehicleByUnitNumber(String unitNumber) async {
    try {
      final snapshot = await _vehiclesCollection
          .where('unit_number', isEqualTo: unitNumber)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return Vehicle.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
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
      mileage: mileage ?? 0.0,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _vehiclesCollection.doc(vehicle.id).set(vehicle.toJson());
    return vehicle;
  }

  /// Update vehicle
  Future<void> updateVehicle(Vehicle vehicle) async {
    final updated = vehicle.copyWith(updatedAt: DateTime.now());
    await _vehiclesCollection.doc(vehicle.id).update(updated.toJson());
  }

  /// Update vehicle mileage
  Future<void> updateVehicleMileage(String id, double mileage) async {
    await _vehiclesCollection.doc(id).update({
      'mileage': mileage,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Update last inspection date
  Future<void> updateLastInspectionDate(String id, DateTime date) async {
    await _vehiclesCollection.doc(id).update({
      'last_inspection_date': date.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Deactivate vehicle
  Future<void> deactivateVehicle(String id) async {
    await _vehiclesCollection.doc(id).update({'is_active': false});
  }

  /// Activate vehicle
  Future<void> activateVehicle(String id) async {
    await _vehiclesCollection.doc(id).update({'is_active': true});
  }

  /// Delete vehicle
  Future<void> deleteVehicle(String id) async {
    await _vehiclesCollection.doc(id).delete();
  }

  /// Search vehicles by various criteria
  Future<List<Vehicle>> searchVehicles(String query) async {
    // Client-side search for flexibility
    final vehicles = await fetchAllVehicles();
    final lowercaseQuery = query.toLowerCase();
    
    return vehicles.where((vehicle) =>
            vehicle.unitNumber.toLowerCase().contains(lowercaseQuery) ||
            vehicle.make.toLowerCase().contains(lowercaseQuery) ||
            vehicle.model.toLowerCase().contains(lowercaseQuery) ||
            vehicle.plateNumber.toLowerCase().contains(lowercaseQuery) ||
            vehicle.vinNumber.toLowerCase().contains(lowercaseQuery) ||
            (vehicle.trailerNumber?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList();
  }

  /// Get vehicles due for inspection (over 30 days since last inspection)
  Future<List<Vehicle>> getVehiclesDueForInspection() async {
    final activeVehicles = await getActiveVehicles();
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    
    return activeVehicles.where((vehicle) =>
            vehicle.lastInspectionDate == null ||
            vehicle.lastInspectionDate!.isBefore(thirtyDaysAgo))
        .toList();
  }

  /// Get vehicle statistics
  Future<Map<String, dynamic>> getVehicleStats() async {
    final vehicles = await fetchAllVehicles();
    final activeVehicles = vehicles.where((v) => v.isActive).toList();
    final dueForInspection = activeVehicles.where((vehicle) {
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        return vehicle.lastInspectionDate == null ||
               vehicle.lastInspectionDate!.isBefore(thirtyDaysAgo);
    }).toList();

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
        isActive: true,
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
        isActive: true,
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
        isActive: true,
      ),
    ];

    for (final vehicle in sampleVehicles) {
      await _vehiclesCollection.doc(vehicle.id).set(vehicle.toJson());
    }
  }
}