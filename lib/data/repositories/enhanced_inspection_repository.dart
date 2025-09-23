import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/inspection_models.dart';
import '../models/sync_models.dart';
import '../datasources/database_service.dart';
import '../../core/services/api_service.dart';
import '../../core/services/sync_service.dart';
import '../../core/exceptions/api_exceptions.dart';
import '../../core/config/api_config.dart';

/// Enhanced repository for inspection operations with PostgreSQL sync
class EnhancedInspectionRepository {
  static EnhancedInspectionRepository? _instance;
  static EnhancedInspectionRepository get instance => _instance ??= EnhancedInspectionRepository._();
  
  final DatabaseService _dbService;
  final ApiService _apiService;
  final SyncService _syncService;

  EnhancedInspectionRepository._() 
    : _dbService = DatabaseService.instance,
      _apiService = ApiService.instance,
      _syncService = SyncService.instance;

  /// Constructor for testing with dependency injection
  EnhancedInspectionRepository.forTesting({
    required DatabaseService databaseService,
    required ApiService apiService,
    required SyncService syncService,
  }) : _dbService = databaseService,
       _apiService = apiService,
       _syncService = syncService;

  /// Get all inspections (local first, then sync if needed)
  Future<List<Inspection>> getAllInspections({bool forceSync = false}) async {
    try {
      // Get local inspections first
      final localInspections = _dbService.inspectionsBox.values
          .where((inspection) => !inspection.isDeleted)
          .toList();

      // If force sync or no local data, try to sync from server
      if (forceSync || localInspections.isEmpty) {
        await _syncInspectionsFromServer();
        // Get updated local data after sync
        return _dbService.inspectionsBox.values
            .where((inspection) => !inspection.isDeleted)
            .toList();
      }

      return localInspections;
    } catch (e) {
      // Return local data even if sync fails
      return _dbService.inspectionsBox.values
          .where((inspection) => !inspection.isDeleted)
          .toList();
    }
  }

  /// Get inspection by ID
  Future<Inspection?> getInspectionById(String id) async {
    try {
      // Check local first
      final localInspection = _dbService.inspectionsBox.get(id);
      if (localInspection != null && !localInspection.isDeleted) {
        return localInspection;
      }

      // Try to fetch from server if not found locally
      try {
        final response = await _apiService.get<Map<String, dynamic>>(
          '${ApiConfig.inspectionsEndpoint}/$id',
        );
        final inspection = Inspection.fromJson(response);
        
        // Store locally
        await _dbService.inspectionsBox.put(id, inspection);
        return inspection;
      } on ApiException catch (e) {
        if (e.type == ApiErrorType.notFound) {
          return null;
        }
        rethrow;
      }
    } catch (e) {
      return null;
    }
  }

  /// Create new inspection
  Future<Inspection> createInspection(Inspection inspection) async {
    try {
      // Store locally first
      final now = DateTime.now();
      final inspectionWithSync = inspection.copyWith(
        createdAt: now,
        updatedAt: now,
        syncStatus: SyncStatus.pending,
        version: 1,
      );

      await _dbService.inspectionsBox.put(inspection.id, inspectionWithSync);

      // Mark for sync
      await _syncService.markForSync(
        'Inspection',
        inspection.id,
        SyncOperation.create,
        data: inspectionWithSync.toJson(),
      );

      // Try immediate sync if connected
      try {
        await _syncService.syncEntity('Inspection', inspection.id);
      } catch (e) {
        // Sync will be retried later, continue with local operation
      }

      return inspectionWithSync;
    } catch (e) {
      rethrow;
    }
  }

  /// Update existing inspection
  Future<Inspection> updateInspection(Inspection inspection) async {
    try {
      final now = DateTime.now();
      final updatedInspection = inspection.copyWith(
        updatedAt: now,
        syncStatus: SyncStatus.pending,
        version: inspection.version + 1,
      );

      // Store locally
      await _dbService.inspectionsBox.put(inspection.id, updatedInspection);

      // Mark for sync
      await _syncService.markForSync(
        'Inspection',
        inspection.id,
        SyncOperation.update,
        data: updatedInspection.toJson(),
      );

      // Try immediate sync if connected
      try {
        await _syncService.syncEntity('Inspection', inspection.id);
      } catch (e) {
        // Sync will be retried later
      }

      return updatedInspection;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete inspection (soft delete)
  Future<void> deleteInspection(String id) async {
    try {
      final inspection = _dbService.inspectionsBox.get(id);
      if (inspection == null) return;

      final deletedInspection = inspection.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        version: inspection.version + 1,
      );

      // Store locally with deleted flag
      await _dbService.inspectionsBox.put(id, deletedInspection);

      // Mark for sync
      await _syncService.markForSync(
        'Inspection',
        id,
        SyncOperation.delete,
      );

      // Try immediate sync if connected
      try {
        await _syncService.syncEntity('Inspection', id);
      } catch (e) {
        // Sync will be retried later
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get inspections by driver ID
  Future<List<Inspection>> getInspectionsByDriverId(String driverId) async {
    try {
      final allInspections = await getAllInspections();
      return allInspections
          .where((inspection) => inspection.driverId == driverId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get inspections by vehicle ID
  Future<List<Inspection>> getInspectionsByVehicleId(String vehicleId) async {
    try {
      final allInspections = await getAllInspections();
      return allInspections
          .where((inspection) => inspection.vehicle.id == vehicleId)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get inspections by status
  Future<List<Inspection>> getInspectionsByStatus(InspectionStatus status) async {
    try {
      final allInspections = await getAllInspections();
      return allInspections
          .where((inspection) => inspection.status == status)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get inspections within date range
  Future<List<Inspection>> getInspectionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final allInspections = await getAllInspections();
      return allInspections
          .where((inspection) =>
              inspection.createdAt.isAfter(startDate) &&
              inspection.createdAt.isBefore(endDate))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get pending sync inspections
  Future<List<Inspection>> getPendingSyncInspections() async {
    try {
      return _dbService.inspectionsBox.values
          .where((inspection) => inspection.syncStatus == SyncStatus.pending)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Sync inspections from server
  Future<void> _syncInspectionsFromServer() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.inspectionsEndpoint,
        queryParameters: {
          'limit': 100,
          'offset': 0,
        },
      );

      final inspections = (response['data'] as List)
          .map((json) => Inspection.fromJson(json))
          .toList();

      // Store inspections locally
      for (final inspection in inspections) {
        final existingInspection = _dbService.inspectionsBox.get(inspection.id);
        
        if (existingInspection == null || 
            inspection.version > existingInspection.version) {
          // Update with synced status
          final syncedInspection = inspection.copyWith(
            syncStatus: SyncStatus.synced,
            lastSyncAt: DateTime.now(),
          );
          
          await _dbService.inspectionsBox.put(inspection.id, syncedInspection);
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Clear all local inspections (for testing/reset)
  Future<void> clearAllInspections() async {
    try {
      await _dbService.inspectionsBox.clear();
    } catch (e) {
      rethrow;
    }
  }

  /// Get sync statistics for inspections
  Future<Map<String, int>> getSyncStatistics() async {
    try {
      final allInspections = _dbService.inspectionsBox.values.toList();
      
      return {
        'total': allInspections.length,
        'synced': allInspections.where((i) => i.syncStatus == SyncStatus.synced).length,
        'pending': allInspections.where((i) => i.syncStatus == SyncStatus.pending).length,
        'failed': allInspections.where((i) => i.syncStatus == SyncStatus.failed).length,
        'conflict': allInspections.where((i) => i.syncStatus == SyncStatus.conflict).length,
        'deleted': allInspections.where((i) => i.isDeleted).length,
      };
    } catch (e) {
      return {};
    }
  }

  /// Update inspection item
  Future<void> updateInspectionItem(String inspectionId, InspectionItem item) async {
    try {
      final inspection = await getInspectionById(inspectionId);
      if (inspection == null) {
        throw Exception('Inspection not found: $inspectionId');
      }

      // Update the specific item in the inspection
      final updatedItems = inspection.items.map((existingItem) {
        if (existingItem.id == item.id) {
          return item;
        }
        return existingItem;
      }).toList();

      final updatedInspection = inspection.copyWith(
        items: updatedItems,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        version: inspection.version + 1,
      );

      await updateInspection(updatedInspection);
    } catch (e) {
      rethrow;
    }
  }

  /// Complete inspection
  Future<void> completeInspection(String inspectionId, String signature, {String? overallNotes}) async {
    try {
      final inspection = await getInspectionById(inspectionId);
      if (inspection == null) {
        throw Exception('Inspection not found: $inspectionId');
      }

      final completedInspection = inspection.copyWith(
        status: InspectionStatus.completed,
        signature: signature,
        overallNotes: overallNotes,
        completedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        version: inspection.version + 1,
      );

      await updateInspection(completedInspection);
    } catch (e) {
      rethrow;
    }
  }

  /// Sync from server
  Future<void> syncFromServer() async {
    try {
      await _syncInspectionsFromServer();
    } catch (e) {
      rethrow;
    }
  }

  /// Get inspection statistics
  Future<Map<String, dynamic>> getInspectionStats() async {
    try {
      final allInspections = await getAllInspections();
      final completedInspections = allInspections.where((i) => i.status == InspectionStatus.completed).toList();
      final inProgressInspections = allInspections.where((i) => i.status == InspectionStatus.inProgress).toList();
      final pendingInspections = allInspections.where((i) => i.status == InspectionStatus.pending).toList();

      return {
        'total': allInspections.length,
        'completed': completedInspections.length,
        'in_progress': inProgressInspections.length,
        'pending': pendingInspections.length,
        'completion_rate': allInspections.isEmpty ? 0.0 : (completedInspections.length / allInspections.length) * 100,
      };
    } catch (e) {
      return {
        'total': 0,
        'completed': 0,
        'in_progress': 0,
        'pending': 0,
        'completion_rate': 0.0,
      };
    }
  }
}