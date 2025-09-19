import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/inspection_models.dart';
import '../models/sync_models.dart';
import '../datasources/database_service.dart';
import '../../core/services/api_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/exceptions/api_exceptions.dart';
import '../../core/config/api_config.dart';

/// Enhanced repository for vehicle operations with PostgreSQL sync
class EnhancedVehicleRepository {
  static EnhancedVehicleRepository? _instance;
  static EnhancedVehicleRepository get instance => _instance ??= EnhancedVehicleRepository._();
  EnhancedVehicleRepository._();

  final DatabaseService _dbService = DatabaseService.instance;
  final ApiService _apiService = ApiService.instance;
  final SyncService _syncService = SyncService.instance;

  /// Get all vehicles (local first, then sync if needed)
  Future<List<Vehicle>> getAllVehicles({bool forceSync = false}) async {
    try {
      // Get local vehicles first
      final localVehicles = _dbService.vehiclesBox.values
          .where((vehicle) => !vehicle.isDeleted)
          .toList();

      // If force sync or no local data, try to sync from server
      if (forceSync || localVehicles.isEmpty) {
        await _syncVehiclesFromServer();
        // Get updated local data after sync
        return _dbService.vehiclesBox.values
            .where((vehicle) => !vehicle.isDeleted)
            .toList();
      }

      return localVehicles;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vehicles: $e');
      }
      // Return local data even if sync fails
      return _dbService.vehiclesBox.values
          .where((vehicle) => !vehicle.isDeleted)
          .toList();
    }
  }

  /// Get vehicle by ID
  Future<Vehicle?> getVehicleById(String id) async {
    try {
      // Check local first
      final localVehicle = _dbService.vehiclesBox.get(id);
      if (localVehicle != null && !localVehicle.isDeleted) {
        return localVehicle;
      }

      // Try to fetch from server if not found locally
      try {
        final response = await _apiService.get<Map<String, dynamic>>(
          '${ApiConfig.vehiclesEndpoint}/$id',
        );
        final vehicle = Vehicle.fromJson(response);
        
        // Store locally
        await _dbService.vehiclesBox.put(id, vehicle);
        return vehicle;
      } on ApiException catch (e) {
        if (e.type == ApiErrorType.notFound) {
          return null;
        }
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vehicle by ID: $e');
      }
      return null;
    }
  }

  /// Get vehicle by unit number
  Future<Vehicle?> getVehicleByUnitNumber(String unitNumber) async {
    try {
      // Check local first
      final localVehicles = _dbService.vehiclesBox.values
          .where((vehicle) => 
              vehicle.unitNumber == unitNumber && !vehicle.isDeleted)
          .toList();
      
      if (localVehicles.isNotEmpty) {
        return localVehicles.first;
      }

      // Try to fetch from server
      try {
        final response = await _apiService.get<Map<String, dynamic>>(
          ApiConfig.vehiclesEndpoint,
          queryParameters: {'unitNumber': unitNumber},
        );
        
        final vehicles = (response['data'] as List)
            .map((json) => Vehicle.fromJson(json))
            .toList();
        
        if (vehicles.isNotEmpty) {
          final vehicle = vehicles.first;
          // Store locally
          await _dbService.vehiclesBox.put(vehicle.id, vehicle);
          return vehicle;
        }
        
        return null;
      } on ApiException catch (e) {
        if (e.type == ApiErrorType.notFound) {
          return null;
        }
        rethrow;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vehicle by unit number: $e');
      }
      return null;
    }
  }

  /// Create new vehicle
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    try {
      // Store locally first
      final now = DateTime.now();
      final vehicleWithSync = vehicle.copyWith(
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
        version: 1,
      );

      await _dbService.vehiclesBox.put(vehicle.id, vehicleWithSync);

      // Mark for sync
      await _syncService.markForSync(
        'Vehicle',
        vehicle.id,
        SyncOperation.create,
        data: vehicleWithSync.toJson(),
      );

      // Try immediate sync if connected
      try {
        await _syncService.syncEntity('Vehicle', vehicle.id);
      } catch (e) {
        // Sync will be retried later, continue with local operation
        if (kDebugMode) {
          print('Immediate sync failed, will retry later: $e');
        }
      }

      return vehicleWithSync;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating vehicle: $e');
      }
      rethrow;
    }
  }

  /// Update existing vehicle
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    try {
      final now = DateTime.now();
      final updatedVehicle = vehicle.copyWith(
        updatedAt: now,
        syncStatus: SyncStatus.pending,
        version: vehicle.version + 1,
      );

      // Store locally
      await _dbService.vehiclesBox.put(vehicle.id, updatedVehicle);

      // Mark for sync
      await _syncService.markForSync(
        'Vehicle',
        vehicle.id,
        SyncOperation.update,
        data: updatedVehicle.toJson(),
      );

      // Try immediate sync if connected
      try {
        await _syncService.syncEntity('Vehicle', vehicle.id);
      } catch (e) {
        // Sync will be retried later
        if (kDebugMode) {
          print('Immediate sync failed, will retry later: $e');
        }
      }

      return updatedVehicle;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating vehicle: $e');
      }
      rethrow;
    }
  }

  /// Delete vehicle (soft delete)
  Future<void> deleteVehicle(String id) async {
    try {
      final vehicle = _dbService.vehiclesBox.get(id);
      if (vehicle == null) return;

      final deletedVehicle = vehicle.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        version: vehicle.version + 1,
      );

      // Store locally with deleted flag
      await _dbService.vehiclesBox.put(id, deletedVehicle);

      // Mark for sync
      await _syncService.markForSync(
        'Vehicle',
        id,
        SyncOperation.delete,
      );

      // Try immediate sync if connected
      try {
        await _syncService.syncEntity('Vehicle', id);
      } catch (e) {
        // Sync will be retried later
        if (kDebugMode) {
          print('Immediate sync failed, will retry later: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting vehicle: $e');
      }
      rethrow;
    }
  }

  /// Search vehicles by query
  Future<List<Vehicle>> searchVehicles({
    String? make,
    String? model,
    String? unitNumber,
    bool? isActive,
    String? query,
  }) async {
    try {
      final allVehicles = await getAllVehicles();
      
      return allVehicles.where((vehicle) {
        bool matches = true;
        
        // If query is provided, search across multiple fields
        if (query != null && query.isNotEmpty) {
          final lowercaseQuery = query.toLowerCase();
          matches = matches && (
            vehicle.unitNumber.toLowerCase().contains(lowercaseQuery) ||
            vehicle.make.toLowerCase().contains(lowercaseQuery) ||
            vehicle.model.toLowerCase().contains(lowercaseQuery) ||
            vehicle.plateNumber.toLowerCase().contains(lowercaseQuery) ||
            vehicle.vinNumber.toLowerCase().contains(lowercaseQuery)
          );
        }
        
        if (make != null && make.isNotEmpty) {
          matches = matches && 
              vehicle.make.toLowerCase().contains(make.toLowerCase());
        }
        
        if (model != null && model.isNotEmpty) {
          matches = matches && 
              vehicle.model.toLowerCase().contains(model.toLowerCase());
        }
        
        if (unitNumber != null && unitNumber.isNotEmpty) {
          matches = matches && 
              vehicle.unitNumber.toLowerCase().contains(unitNumber.toLowerCase());
        }
        
        if (isActive != null) {
          matches = matches && vehicle.isActive == isActive;
        }
        
        return matches;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching vehicles: $e');
      }
      return [];
    }
  }

  /// Get active vehicles only
  Future<List<Vehicle>> getActiveVehicles() async {
    try {
      final allVehicles = await getAllVehicles();
      return allVehicles
          .where((vehicle) => vehicle.isActive)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting active vehicles: $e');
      }
      return [];
    }
  }

  /// Get vehicles by make
  Future<List<Vehicle>> getVehiclesByMake(String make) async {
    try {
      final allVehicles = await getAllVehicles();
      return allVehicles
          .where((vehicle) => 
              vehicle.make.toLowerCase() == make.toLowerCase())
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vehicles by make: $e');
      }
      return [];
    }
  }

  /// Get vehicles by year range
  Future<List<Vehicle>> getVehiclesByYearRange(int startYear, int endYear) async {
    try {
      final allVehicles = await getAllVehicles();
      return allVehicles
          .where((vehicle) => 
              vehicle.year >= startYear && vehicle.year <= endYear)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vehicles by year range: $e');
      }
      return [];
    }
  }

  /// Get pending sync vehicles
  Future<List<Vehicle>> getPendingSyncVehicles() async {
    try {
      return _dbService.vehiclesBox.values
          .where((vehicle) => vehicle.syncStatus == SyncStatus.pending)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pending sync vehicles: $e');
      }
      return [];
    }
  }

  /// Sync vehicles from server
  Future<void> _syncVehiclesFromServer() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.vehiclesEndpoint,
        queryParameters: {
          'limit': 100,
          'offset': 0,
        },
      );

      final vehicles = (response['data'] as List)
          .map((json) => Vehicle.fromJson(json))
          .toList();

      // Store vehicles locally
      for (final vehicle in vehicles) {
        final existingVehicle = _dbService.vehiclesBox.get(vehicle.id);
        
        if (existingVehicle == null || 
            vehicle.version > existingVehicle.version) {
          // Update with synced status
          final syncedVehicle = vehicle.copyWith(
            syncStatus: SyncStatus.synced,
            lastSyncAt: DateTime.now(),
          );
          
          await _dbService.vehiclesBox.put(vehicle.id, syncedVehicle);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing vehicles from server: $e');
      }
      rethrow;
    }
  }

  /// Clear all local vehicles (for testing/reset)
  Future<void> clearAllVehicles() async {
    try {
      await _dbService.vehiclesBox.clear();
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing vehicles: $e');
      }
      rethrow;
    }
  }

  /// Get sync statistics for vehicles
  Future<Map<String, dynamic>> getSyncStatistics() async {
    try {
      final allVehicles = _dbService.vehiclesBox.values.toList();
      
      final makeCount = <String, int>{};
      final yearCount = <int, int>{};
      int totalActive = 0;
      int totalInactive = 0;
      
      for (final vehicle in allVehicles) {
        // Count by make
        makeCount[vehicle.make] = (makeCount[vehicle.make] ?? 0) + 1;
        
        // Count by year
        yearCount[vehicle.year] = (yearCount[vehicle.year] ?? 0) + 1;
        
        // Count active/inactive
        if (vehicle.isActive) {
          totalActive++;
        } else {
          totalInactive++;
        }
      }
      
      return {
        'total': allVehicles.length,
        'active': totalActive,
        'inactive': totalInactive,
        'makes': makeCount,
        'years': yearCount,
        'average_year': yearCount.isEmpty ? 0 : 
            yearCount.entries.map((e) => e.key * e.value).reduce((a, b) => a + b) / 
            allVehicles.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vehicle statistics: $e');
      }
      return {
        'total': 0,
        'active': 0,
        'inactive': 0,
        'makes': <String, int>{},
        'years': <int, int>{},
        'average_year': 0,
      };
    }
  }

  /// Get vehicles due for inspection
  Future<List<Vehicle>> getVehiclesDueForInspection() async {
    try {
      final allVehicles = await getAllVehicles();
      final now = DateTime.now();
      
      return allVehicles.where((vehicle) {
        if (!vehicle.isActive || vehicle.isDeleted) return false;
        
        // If no last inspection date, it's due
        if (vehicle.lastInspectionDate == null) return true;
        
        // Check if it's been more than 24 hours since last inspection
        final daysSinceInspection = now.difference(vehicle.lastInspectionDate!).inDays;
        return daysSinceInspection >= 1;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vehicles due for inspection: $e');
      }
      return [];
    }
  }

  /// Sync from server
  Future<void> syncFromServer() async {
    try {
      await _syncVehiclesFromServer();
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing from server: $e');
      }
      rethrow;
    }
  }

  /// Get vehicle statistics
  Future<Map<String, dynamic>> getVehicleStats() async {
    return await getVehicleStatistics();
  }

  /// Bulk update vehicles
  Future<List<Vehicle>> bulkUpdateVehicles(List<Vehicle> vehicles) async {
    try {
      final updatedVehicles = <Vehicle>[];
      
      for (final vehicle in vehicles) {
        final updatedVehicle = await updateVehicle(vehicle);
        updatedVehicles.add(updatedVehicle);
      }
      
      return updatedVehicles;
    } catch (e) {
      if (kDebugMode) {
        print('Error bulk updating vehicles: $e');
      }
      rethrow;
    }
  }

  /// Get vehicle statistics
  Future<Map<String, dynamic>> getVehicleStatistics() async {
    try {
      final allVehicles = await getAllVehicles();
      
      final makeCount = <String, int>{};
      final yearCount = <int, int>{};
      int totalActive = 0;
      int totalInactive = 0;
      
      for (final vehicle in allVehicles) {
        // Count by make
        makeCount[vehicle.make] = (makeCount[vehicle.make] ?? 0) + 1;
        
        // Count by year
        yearCount[vehicle.year] = (yearCount[vehicle.year] ?? 0) + 1;
        
        // Count active/inactive
        if (vehicle.isActive) {
          totalActive++;
        } else {
          totalInactive++;
        }
      }
      
      return {
        'total': allVehicles.length,
        'active': totalActive,
        'inactive': totalInactive,
        'byMake': makeCount,
        'byYear': yearCount,
        'averageYear': yearCount.isEmpty ? 0 : 
            yearCount.entries.map((e) => e.key * e.value).reduce((a, b) => a + b) / 
            allVehicles.length,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vehicle statistics: $e');
      }
      return {};
    }
  }
}