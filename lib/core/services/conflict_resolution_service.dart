import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../exceptions/api_exceptions.dart';
import '../../data/models/sync_models.dart';
import '../../data/models/inspection_models.dart';
import '../../data/datasources/database_service.dart';
import 'api_service.dart';

/// Service for handling sync conflicts with PostgreSQL backend
class ConflictResolutionService {
  static ConflictResolutionService? _instance;
  static ConflictResolutionService get instance => _instance ??= ConflictResolutionService._();
  ConflictResolutionService._();

  final DatabaseService _dbService = DatabaseService.instance;
  final ApiService _apiService = ApiService.instance;

  /// Resolve conflict based on resolution strategy
  Future<Map<String, dynamic>> resolveConflict(
    SyncConflict conflict,
    ConflictResolution resolution, {
    Map<String, dynamic>? mergedData,
  }) async {
    try {
      switch (resolution) {
        case ConflictResolution.useLocal:
          return await _resolveUseLocal(conflict);
        
        case ConflictResolution.useServer:
          return await _resolveUseServer(conflict);
        
        case ConflictResolution.merge:
          if (mergedData == null) {
            throw ValidationException(
              'Merged data is required for merge resolution',
              {},
            );
          }
          return await _resolveMerge(conflict, mergedData);
        
        case ConflictResolution.manual:
          return await _resolveCreateNew(conflict);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving conflict: $e');
      }
      rethrow;
    }
  }

  /// Detect conflicts between local and server data
  Future<List<SyncConflict>> detectConflicts(
    String entityType,
    List<Map<String, dynamic>> localEntities,
    List<Map<String, dynamic>> serverEntities,
  ) async {
    final conflicts = <SyncConflict>[];

    try {
      // Create maps for efficient lookup
      final localMap = <String, Map<String, dynamic>>{};
      final serverMap = <String, Map<String, dynamic>>{};

      for (final entity in localEntities) {
        localMap[entity['id']] = entity;
      }

      for (final entity in serverEntities) {
        serverMap[entity['id']] = entity;
      }

      // Check for conflicts
      for (final localEntity in localEntities) {
        final id = localEntity['id'] as String;
        final serverEntity = serverMap[id];

        if (serverEntity != null) {
          final conflict = await _checkForConflict(
            entityType,
            id,
            localEntity,
            serverEntity,
          );
          
          if (conflict != null) {
            conflicts.add(conflict);
          }
        }
      }

      return conflicts;
    } catch (e) {
      if (kDebugMode) {
        print('Error detecting conflicts: $e');
      }
      return [];
    }
  }

  /// Check if two entities have conflicts
  Future<SyncConflict?> _checkForConflict(
    String entityType,
    String entityId,
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
  ) async {
    try {
      // Compare versions
      final localVersion = localData['version'] as int? ?? 1;
      final serverVersion = serverData['version'] as int? ?? 1;

      // Compare update timestamps
      final localUpdatedAt = DateTime.parse(localData['updatedAt'] as String);
      final serverUpdatedAt = DateTime.parse(serverData['updatedAt'] as String);

      // Check for conflicts
      bool hasConflict = false;

      if (localVersion != serverVersion && 
          localUpdatedAt.isAfter(serverUpdatedAt.subtract(const Duration(seconds: 1))) &&
          localUpdatedAt.isBefore(serverUpdatedAt.add(const Duration(seconds: 1)))) {
        // Concurrent modifications
        hasConflict = true;
      } else if (_hasDataDifferences(localData, serverData)) {
        // Data differences
        hasConflict = true;
      }

      if (!hasConflict) return null;

      return SyncConflict(
        id: '${entityType}_${entityId}_${DateTime.now().millisecondsSinceEpoch}',
        entityType: entityType,
        entityId: entityId,
        localData: localData,
        serverData: serverData,
        detectedAt: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error checking for conflict: $e');
      }
      return null;
    }
  }

  /// Check if two data objects have significant differences
  bool _hasDataDifferences(
    Map<String, dynamic> localData,
    Map<String, dynamic> serverData,
  ) {
    // Exclude sync-related fields from comparison
    final excludeFields = {
      'syncStatus', 'lastSyncAt', 'serverVersion', 'conflictData',
      'createdAt', 'updatedAt', 'version'
    };

    final localFiltered = Map<String, dynamic>.from(localData)
      ..removeWhere((key, value) => excludeFields.contains(key));
    
    final serverFiltered = Map<String, dynamic>.from(serverData)
      ..removeWhere((key, value) => excludeFields.contains(key));

    return !_deepEquals(localFiltered, serverFiltered);
  }

  /// Deep equality check for maps
  bool _deepEquals(dynamic a, dynamic b) {
    if (a.runtimeType != b.runtimeType) return false;
    
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) {
          return false;
        }
      }
      return true;
    }
    
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      
      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }
    
    return a == b;
  }

  /// Resolve conflict using local data
  Future<Map<String, dynamic>> _resolveUseLocal(SyncConflict conflict) async {
    try {
      // Update server with local data
      final endpoint = _getEntityEndpoint(conflict.entityType, conflict.entityId);
      
      final localData = Map<String, dynamic>.from(conflict.localData);
      final currentLocalVersion = conflict.localData['version'] as int? ?? 0;
      localData['version'] = currentLocalVersion + 1;
      localData['updatedAt'] = DateTime.now().toIso8601String();

      await _apiService.put<Map<String, dynamic>>(endpoint, data: localData);

      // Update local entity with new version
      await _updateLocalEntity(conflict.entityType, conflict.entityId, localData);

      return localData;
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving conflict with local data: $e');
      }
      rethrow;
    }
  }

  /// Resolve conflict using server data
  Future<Map<String, dynamic>> _resolveUseServer(SyncConflict conflict) async {
    try {
      // Update local with server data
      final serverData = Map<String, dynamic>.from(conflict.serverData);
      serverData['syncStatus'] = SyncStatus.synced.name;
      serverData['lastSyncAt'] = DateTime.now().toIso8601String();

      await _updateLocalEntity(conflict.entityType, conflict.entityId, serverData);

      return serverData;
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving conflict with server data: $e');
      }
      rethrow;
    }
  }

  /// Resolve conflict by merging data
  Future<Map<String, dynamic>> _resolveMerge(
    SyncConflict conflict,
    Map<String, dynamic> mergedData,
  ) async {
    try {
      // Validate merged data
      _validateMergedData(conflict.entityType, mergedData);

      // Update version and timestamp
      final finalData = Map<String, dynamic>.from(mergedData);
      final serverVersion = conflict.serverData['version'] as int? ?? 0;
      final localVersion = conflict.localData['version'] as int? ?? 0;
      finalData['version'] = (serverVersion > localVersion 
          ? serverVersion : localVersion) + 1;
      finalData['updatedAt'] = DateTime.now().toIso8601String();

      // Update server
      final endpoint = _getEntityEndpoint(conflict.entityType, conflict.entityId);
      await _apiService.put<Map<String, dynamic>>(endpoint, data: finalData);

      // Update local
      finalData['syncStatus'] = SyncStatus.synced.name;
      finalData['lastSyncAt'] = DateTime.now().toIso8601String();
      await _updateLocalEntity(conflict.entityType, conflict.entityId, finalData);

      return finalData;
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving conflict with merged data: $e');
      }
      rethrow;
    }
  }

  /// Resolve conflict by creating new entity
  Future<Map<String, dynamic>> _resolveCreateNew(SyncConflict conflict) async {
    try {
      // Create new entity with local data
      final newData = Map<String, dynamic>.from(conflict.localData);
      newData['id'] = _generateNewId();
      newData['version'] = 1;
      newData['createdAt'] = DateTime.now().toIso8601String();
      newData['updatedAt'] = DateTime.now().toIso8601String();

      // Create on server
      final endpoint = _getEntityEndpoint(conflict.entityType);
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint,
        data: newData,
      );

      // Update local with server response
      final serverData = Map<String, dynamic>.from(response);
      serverData['syncStatus'] = SyncStatus.synced.name;
      serverData['lastSyncAt'] = DateTime.now().toIso8601String();

      // Store new entity locally
      await _storeLocalEntity(conflict.entityType, serverData['id'], serverData);

      // Keep original entity with server data
      await _resolveUseServer(conflict);

      return serverData;
    } catch (e) {
      if (kDebugMode) {
        print('Error resolving conflict by creating new entity: $e');
      }
      rethrow;
    }
  }

  /// Get entity endpoint
  String _getEntityEndpoint(String entityType, [String? entityId]) {
    String baseEndpoint;
    
    switch (entityType) {
      case 'Vehicle':
        baseEndpoint = '/api/vehicles';
        break;
      case 'Inspection':
        baseEndpoint = '/api/inspections';
        break;
      case 'User':
        baseEndpoint = '/api/users';
        break;
      default:
        throw ArgumentError('Unknown entity type: $entityType');
    }

    return entityId != null ? '$baseEndpoint/$entityId' : baseEndpoint;
  }

  /// Update local entity
  Future<void> _updateLocalEntity(
    String entityType,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    try {
      switch (entityType) {
        case 'Vehicle':
          final vehicle = Vehicle.fromJson(data);
          await _dbService.vehiclesBox.put(entityId, vehicle);
          break;
        case 'Inspection':
          final inspection = Inspection.fromJson(data);
          await _dbService.inspectionsBox.put(entityId, inspection);
          break;
        case 'User':
          // Handle user entity if needed
          break;
        default:
          throw ArgumentError('Unknown entity type: $entityType');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating local entity: $e');
      }
      rethrow;
    }
  }

  /// Store new local entity
  Future<void> _storeLocalEntity(
    String entityType,
    String entityId,
    Map<String, dynamic> data,
  ) async {
    await _updateLocalEntity(entityType, entityId, data);
  }

  /// Validate merged data
  void _validateMergedData(String entityType, Map<String, dynamic> data) {
    final requiredFields = _getRequiredFields(entityType);
    
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null) {
        throw ValidationException(
          'Required field $field is missing in merged data',
          {field: ['Field is required']},
        );
      }
    }
  }

  /// Get required fields for entity type
  List<String> _getRequiredFields(String entityType) {
    switch (entityType) {
      case 'Vehicle':
        return ['id', 'unitNumber', 'make', 'model', 'year'];
      case 'Inspection':
        return ['id', 'driverId', 'driverName', 'vehicle', 'type'];
      case 'User':
        return ['id', 'name', 'email'];
      default:
        return ['id'];
    }
  }

  /// Generate new ID for entity
  String _generateNewId() {
    return 'new_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  /// Get conflict summary for UI display
  Map<String, dynamic> getConflictSummary(SyncConflict conflict) {
    final localData = conflict.localData;
    final serverData = conflict.serverData;
    final differences = <String, Map<String, dynamic>>{};

    // Compare fields and identify differences
    final allKeys = {...localData.keys, ...serverData.keys};
    final excludeFields = {
      'syncStatus', 'lastSyncAt', 'serverVersion', 'conflictData',
      'createdAt', 'updatedAt', 'version'
    };

    for (final key in allKeys) {
      if (excludeFields.contains(key)) continue;
      
      final localValue = localData[key];
      final serverValue = serverData[key];
      
      if (!_deepEquals(localValue, serverValue)) {
        differences[key] = {
          'local': localValue,
          'server': serverValue,
        };
      }
    }

    return {
      'entityType': conflict.entityType,
      'entityId': conflict.entityId,
      'differences': differences,
      'localVersion': conflict.localData['version'] as int? ?? 0,
      'serverVersion': conflict.serverData['version'] as int? ?? 0,
      'detectedAt': conflict.detectedAt.toIso8601String(),
    };
  }

  /// Auto-resolve simple conflicts
  Future<ConflictResolution?> suggestAutoResolution(SyncConflict conflict) async {
    try {
      // Extract version information from data if available
      final serverVersion = conflict.serverData['version'] as int? ?? 0;
      final localVersion = conflict.localData['version'] as int? ?? 0;
      
      // If server version is much newer, suggest using server
      if (serverVersion > localVersion + 1) {
        return ConflictResolution.useServer;
      }

      // If local version is much newer, suggest using local
      if (localVersion > serverVersion + 1) {
        return ConflictResolution.useLocal;
      }

      // If only non-critical fields differ, suggest merge
      final differences = getConflictSummary(conflict)['differences'] as Map<String, dynamic>;
      final nonCriticalFields = {'notes', 'overallNotes', 'signature'};
      
      if (differences.keys.every((key) => nonCriticalFields.contains(key))) {
        return ConflictResolution.merge;
      }

      // Default to manual resolution
      return null;
    } catch (e) {
      rethrow;
    }
  }
}