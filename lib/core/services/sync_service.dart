import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';
import '../../data/models/sync_models.dart';
import '../../data/models/inspection_models.dart';
import '../../data/datasources/database_service.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// Service for handling offline-first synchronization with PostgreSQL backend
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();
  SyncService._();

  final ApiService _apiService = ApiService.instance;
  final AuthService _authService = AuthService.instance;
  final DatabaseService _dbService = DatabaseService.instance;
  
  Timer? _syncTimer;
  bool _isSyncing = false;
  final StreamController<SyncStats> _syncStatsController = StreamController<SyncStats>.broadcast();
  final StreamController<SyncBatch> _syncBatchController = StreamController<SyncBatch>.broadcast();

  /// Stream of sync statistics
  Stream<SyncStats> get syncStatsStream => _syncStatsController.stream;
  
  /// Stream of sync batch updates
  Stream<SyncBatch> get syncBatchStream => _syncBatchController.stream;

  /// Initialize the sync service
  Future<void> initialize() async {
    await _apiService.initialize();
    await _authService.initialize();
    
    // Start periodic sync if authenticated
    if (await _authService.isAuthenticated()) {
      startPeriodicSync();
    }
  }

  /// Start periodic synchronization
  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) async {
      if (await _isConnected() && await _authService.isAuthenticated()) {
        await syncAll();
      }
    });
  }

  /// Stop periodic synchronization
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Perform full synchronization
  Future<SyncBatch> syncAll({bool force = false}) async {
    if (_isSyncing && !force) {
      throw SyncException('Sync already in progress', ApiErrorType.unknown);
    }

    _isSyncing = true;
    final batchId = _generateId();
    final batch = SyncBatch(
      id: batchId,
      startedAt: DateTime.now(),
      status: SyncBatchStatus.running,
      entityIds: [],
      totalEntities: 0,
    );

    try {
      _syncBatchController.add(batch);

      // Get all entities that need syncing
      final pendingEntities = await _getPendingEntities();
      final updatedBatch = batch.copyWith(
        entityIds: pendingEntities.map((e) => e.entityId).toList(),
        totalEntities: pendingEntities.length,
      );
      _syncBatchController.add(updatedBatch);

      // Sync entities in batches
      int processed = 0;
      int successful = 0;
      int failed = 0;
      final errors = <String>[];

      for (final metadata in pendingEntities) {
        try {
          await _syncEntity(metadata);
          successful++;
        } catch (e) {
          failed++;
          errors.add('${metadata.entityType}:${metadata.entityId} - $e');
        }
        
        processed++;
        final progressBatch = updatedBatch.copyWith(
          processedEntities: processed,
          successfulEntities: successful,
          failedEntities: failed,
          errors: errors,
        );
        _syncBatchController.add(progressBatch);
      }

      // Complete the batch
      final completedBatch = updatedBatch.copyWith(
        completedAt: DateTime.now(),
        status: failed == 0 ? SyncBatchStatus.completed : SyncBatchStatus.failed,
        processedEntities: processed,
        successfulEntities: successful,
        failedEntities: failed,
        errors: errors,
      );
      
      _syncBatchController.add(completedBatch);
      await _updateSyncStats();
      
      return completedBatch;
    } catch (e) {
      final failedBatch = batch.copyWith(
        completedAt: DateTime.now(),
        status: SyncBatchStatus.failed,
        errors: [e.toString()],
      );
      _syncBatchController.add(failedBatch);
      rethrow;
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync a specific entity
  Future<void> syncEntity(String entityType, String entityId) async {
    final metadata = await _getSyncMetadata(entityType, entityId);
    if (metadata != null) {
      await _syncEntity(metadata);
      await _updateSyncStats();
    }
  }

  /// Mark entity for sync
  Future<void> markForSync(
    String entityType,
    String entityId,
    SyncOperation operation, {
    Map<String, dynamic>? data,
  }) async {
    final now = DateTime.now();
    final dataHash = data != null ? _generateDataHash(data) : null;
    
    var metadata = await _getSyncMetadata(entityType, entityId);
    
    if (metadata == null) {
      metadata = SyncMetadata(
        entityId: entityId,
        entityType: entityType,
        status: SyncStatus.pending,
        createdAt: now,
        updatedAt: now,
        version: 1,
        dataHash: dataHash,
        pendingOperations: [operation],
      );
    } else {
      final operations = List<SyncOperation>.from(metadata.pendingOperations);
      if (!operations.contains(operation)) {
        operations.add(operation);
      }
      
      metadata = metadata.copyWith(
        status: SyncStatus.pending,
        updatedAt: now,
        dataHash: dataHash,
        pendingOperations: operations,
      );
    }
    
    await _storeSyncMetadata(metadata);
  }

  /// Get sync statistics
  Future<SyncStats> getSyncStats() async {
    final allMetadata = await _getAllSyncMetadata();
    
    final totalEntities = allMetadata.length;
    final syncedEntities = allMetadata.where((m) => m.status == SyncStatus.synced).length;
    final pendingEntities = allMetadata.where((m) => m.status == SyncStatus.pending).length;
    final failedEntities = allMetadata.where((m) => m.status == SyncStatus.failed).length;
    final conflictedEntities = allMetadata.where((m) => m.status == SyncStatus.conflict).length;
    
    final lastSyncAt = allMetadata
        .where((m) => m.lastSyncAt != null)
        .map((m) => m.lastSyncAt!)
        .fold<DateTime?>(null, (prev, curr) => prev == null || curr.isAfter(prev) ? curr : prev);
    
    final entityTypeCounts = <String, int>{};
    for (final metadata in allMetadata) {
      entityTypeCounts[metadata.entityType] = (entityTypeCounts[metadata.entityType] ?? 0) + 1;
    }
    
    return SyncStats(
      totalEntities: totalEntities,
      syncedEntities: syncedEntities,
      pendingEntities: pendingEntities,
      failedEntities: failedEntities,
      conflictedEntities: conflictedEntities,
      lastSyncAt: lastSyncAt,
      entityTypeCounts: entityTypeCounts,
    );
  }

  /// Resolve sync conflict
  Future<void> resolveConflict(
    String conflictId,
    ConflictResolution resolution, {
    Map<String, dynamic>? mergedData,
  }) async {
    // Implementation for conflict resolution
    // This would involve updating the local data based on the resolution strategy
    // and marking the entity for re-sync
  }

  /// Check network connectivity
  Future<bool> _isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Sync individual entity
  Future<void> _syncEntity(SyncMetadata metadata) async {
    try {
      // Update status to syncing
      await _storeSyncMetadata(metadata.copyWith(status: SyncStatus.syncing));

      for (final operation in metadata.pendingOperations) {
        switch (operation) {
          case SyncOperation.create:
            await _syncCreate(metadata);
            break;
          case SyncOperation.update:
            await _syncUpdate(metadata);
            break;
          case SyncOperation.delete:
            await _syncDelete(metadata);
            break;
        }
      }

      // Mark as synced
      await _storeSyncMetadata(metadata.copyWith(
        status: SyncStatus.synced,
        lastSyncAt: DateTime.now(),
        pendingOperations: [],
        errorMessage: null,
        retryCount: 0,
      ));
    } catch (e) {
      // Handle sync failure
      final retryCount = metadata.retryCount + 1;
      final nextRetryAt = DateTime.now().add(Duration(minutes: pow(2, retryCount).toInt()));
      
      await _storeSyncMetadata(metadata.copyWith(
        status: SyncStatus.failed,
        errorMessage: e.toString(),
        retryCount: retryCount,
        nextRetryAt: nextRetryAt,
      ));
      
      rethrow;
    }
  }

  /// Sync create operation
  Future<void> _syncCreate(SyncMetadata metadata) async {
    final entityData = await _getEntityData(metadata.entityType, metadata.entityId);
    if (entityData == null) return;

    final endpoint = _getEntityEndpoint(metadata.entityType);
    final response = await _apiService.post<Map<String, dynamic>>(endpoint, data: entityData);
    
    // Update local entity with server data if needed
    if (response['id'] != metadata.entityId) {
      await _updateLocalEntityId(metadata.entityType, metadata.entityId, response['id']);
    }
  }

  /// Sync update operation
  Future<void> _syncUpdate(SyncMetadata metadata) async {
    final entityData = await _getEntityData(metadata.entityType, metadata.entityId);
    if (entityData == null) return;

    final endpoint = '${_getEntityEndpoint(metadata.entityType)}/${metadata.entityId}';
    
    try {
      await _apiService.put<Map<String, dynamic>>(endpoint, data: entityData);
    } on ApiException catch (e) {
      if (e.type == ApiErrorType.notFound) {
        // Entity doesn't exist on server, create it instead
        await _syncCreate(metadata);
      } else {
        rethrow;
      }
    }
  }

  /// Sync delete operation
  Future<void> _syncDelete(SyncMetadata metadata) async {
    final endpoint = '${_getEntityEndpoint(metadata.entityType)}/${metadata.entityId}';
    
    try {
      await _apiService.delete(endpoint);
    } on ApiException catch (e) {
      if (e.type == ApiErrorType.notFound) {
        // Entity already deleted on server, that's fine
      } else {
        rethrow;
      }
    }
  }

  /// Get entity endpoint based on type
  String _getEntityEndpoint(String entityType) {
    switch (entityType) {
      case 'Vehicle':
        return ApiConfig.vehiclesEndpoint;
      case 'Inspection':
        return ApiConfig.inspectionsEndpoint;
      case 'User':
        return ApiConfig.usersEndpoint;
      default:
        throw ArgumentError('Unknown entity type: $entityType');
    }
  }

  /// Get entity data from local storage
  Future<Map<String, dynamic>?> _getEntityData(String entityType, String entityId) async {
    switch (entityType) {
      case 'Vehicle':
        final vehicle = _dbService.vehiclesBox.get(entityId);
        return vehicle?.toJson();
      case 'Inspection':
        final inspection = _dbService.inspectionsBox.get(entityId);
        return inspection?.toJson();
      case 'User':
        final user = _dbService.usersBox.get(entityId);
        return user?.toJson();
      default:
        return null;
    }
  }

  /// Update local entity ID after server creation
  Future<void> _updateLocalEntityId(String entityType, String oldId, String newId) async {
    // Implementation would depend on the specific entity type
    // This is a placeholder for the actual implementation
  }

  /// Get all pending sync metadata
  Future<List<SyncMetadata>> _getPendingEntities() async {
    // This would retrieve from a sync metadata storage
    // For now, return empty list as placeholder
    return [];
  }

  /// Get sync metadata for specific entity
  Future<SyncMetadata?> _getSyncMetadata(String entityType, String entityId) async {
    // Placeholder implementation
    return null;
  }

  /// Store sync metadata
  Future<void> _storeSyncMetadata(SyncMetadata metadata) async {
    // Placeholder implementation
  }

  /// Get all sync metadata
  Future<List<SyncMetadata>> _getAllSyncMetadata() async {
    // Placeholder implementation
    return [];
  }

  /// Update sync statistics
  Future<void> _updateSyncStats() async {
    final stats = await getSyncStats();
    _syncStatsController.add(stats);
  }

  /// Generate unique ID
  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(1000).toString();
  }

  /// Generate data hash for change detection
  String _generateDataHash(Map<String, dynamic> data) {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _syncStatsController.close();
    _syncBatchController.close();
  }
}