import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sync_models.g.dart';

/// Enumeration for sync status
@HiveType(typeId: 20)
enum SyncStatus {
  @HiveField(0)
  @JsonValue('pending')
  pending,
  
  @HiveField(1)
  @JsonValue('syncing')
  syncing,
  
  @HiveField(2)
  @JsonValue('synced')
  synced,
  
  @HiveField(3)
  @JsonValue('failed')
  failed,
  
  @HiveField(4)
  @JsonValue('conflict')
  conflict,
}

/// Enumeration for sync operation type
@HiveType(typeId: 21)
enum SyncOperation {
  @HiveField(0)
  @JsonValue('create')
  create,
  
  @HiveField(1)
  @JsonValue('update')
  update,
  
  @HiveField(2)
  @JsonValue('delete')
  delete,
}

/// Base mixin for syncable entities
mixin SyncableMixin {
  /// Unique identifier for the entity
  String get id;
  
  /// When the entity was created locally
  DateTime get createdAt;
  
  /// When the entity was last updated locally
  DateTime get updatedAt;
  
  /// Sync status of the entity
  SyncStatus get syncStatus;
  
  /// When the entity was last synced with server
  DateTime? get lastSyncAt;
  
  /// Server-side timestamp for conflict resolution
  DateTime? get serverUpdatedAt;
  
  /// Version number for optimistic locking
  int get version;
  
  /// Hash of the entity data for change detection
  String? get dataHash;
  
  /// Whether the entity has been deleted (soft delete)
  bool get isDeleted;
  
  /// Pending sync operations
  List<SyncOperation> get pendingOperations;
}

/// Model for tracking sync metadata
@HiveType(typeId: 22)
@JsonSerializable()
class SyncMetadata {
  @HiveField(0)
  final String entityId;
  
  @HiveField(1)
  final String entityType;
  
  @HiveField(2)
  final SyncStatus status;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime updatedAt;
  
  @HiveField(5)
  final DateTime? lastSyncAt;
  
  @HiveField(6)
  final DateTime? serverUpdatedAt;
  
  @HiveField(7)
  final int version;
  
  @HiveField(8)
  final String? dataHash;
  
  @HiveField(9)
  final bool isDeleted;
  
  @HiveField(10)
  final List<SyncOperation> pendingOperations;
  
  @HiveField(11)
  final String? errorMessage;
  
  @HiveField(12)
  final int retryCount;
  
  @HiveField(13)
  final DateTime? nextRetryAt;

  SyncMetadata({
    required this.entityId,
    required this.entityType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncAt,
    this.serverUpdatedAt,
    this.version = 1,
    this.dataHash,
    this.isDeleted = false,
    this.pendingOperations = const [],
    this.errorMessage,
    this.retryCount = 0,
    this.nextRetryAt,
  });

  factory SyncMetadata.fromJson(Map<String, dynamic> json) =>
      _$SyncMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$SyncMetadataToJson(this);

  SyncMetadata copyWith({
    String? entityId,
    String? entityType,
    SyncStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncAt,
    DateTime? serverUpdatedAt,
    int? version,
    String? dataHash,
    bool? isDeleted,
    List<SyncOperation>? pendingOperations,
    String? errorMessage,
    int? retryCount,
    DateTime? nextRetryAt,
  }) {
    return SyncMetadata(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      version: version ?? this.version,
      dataHash: dataHash ?? this.dataHash,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingOperations: pendingOperations ?? this.pendingOperations,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }
}

/// Model for sync conflicts
@HiveType(typeId: 23)
@JsonSerializable()
class SyncConflict {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String entityId;
  
  @HiveField(2)
  final String entityType;
  
  @HiveField(3)
  final Map<String, dynamic> localData;
  
  @HiveField(4)
  final Map<String, dynamic> serverData;
  
  @HiveField(5)
  final DateTime detectedAt;
  
  @HiveField(6)
  final ConflictResolution? resolution;
  
  @HiveField(7)
  final DateTime? resolvedAt;
  
  @HiveField(8)
  final String? resolvedBy;

  SyncConflict({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.serverData,
    required this.detectedAt,
    this.resolution,
    this.resolvedAt,
    this.resolvedBy,
  });

  factory SyncConflict.fromJson(Map<String, dynamic> json) =>
      _$SyncConflictFromJson(json);

  Map<String, dynamic> toJson() => _$SyncConflictToJson(this);

  bool get isResolved => resolution != null && resolvedAt != null;
}

/// Enumeration for conflict resolution strategies
@HiveType(typeId: 24)
enum ConflictResolution {
  @HiveField(0)
  @JsonValue('use_local')
  useLocal,
  
  @HiveField(1)
  @JsonValue('use_server')
  useServer,
  
  @HiveField(2)
  @JsonValue('merge')
  merge,
  
  @HiveField(3)
  @JsonValue('manual')
  manual,
}

/// Model for sync batch operations
@HiveType(typeId: 25)
@JsonSerializable()
class SyncBatch {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DateTime startedAt;
  
  @HiveField(2)
  final DateTime? completedAt;
  
  @HiveField(3)
  final SyncBatchStatus status;
  
  @HiveField(4)
  final List<String> entityIds;
  
  @HiveField(5)
  final int totalEntities;
  
  @HiveField(6)
  final int processedEntities;
  
  @HiveField(7)
  final int successfulEntities;
  
  @HiveField(8)
  final int failedEntities;
  
  @HiveField(9)
  final List<String> errors;

  SyncBatch({
    required this.id,
    required this.startedAt,
    this.completedAt,
    required this.status,
    required this.entityIds,
    required this.totalEntities,
    this.processedEntities = 0,
    this.successfulEntities = 0,
    this.failedEntities = 0,
    this.errors = const [],
  });

  factory SyncBatch.fromJson(Map<String, dynamic> json) =>
      _$SyncBatchFromJson(json);

  Map<String, dynamic> toJson() => _$SyncBatchToJson(this);

  double get progress => totalEntities > 0 ? processedEntities / totalEntities : 0.0;
  
  bool get isComplete => status == SyncBatchStatus.completed || status == SyncBatchStatus.failed;

  SyncBatch copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? completedAt,
    SyncBatchStatus? status,
    List<String>? entityIds,
    int? totalEntities,
    int? processedEntities,
    int? successfulEntities,
    int? failedEntities,
    List<String>? errors,
  }) {
    return SyncBatch(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      entityIds: entityIds ?? this.entityIds,
      totalEntities: totalEntities ?? this.totalEntities,
      processedEntities: processedEntities ?? this.processedEntities,
      successfulEntities: successfulEntities ?? this.successfulEntities,
      failedEntities: failedEntities ?? this.failedEntities,
      errors: errors ?? this.errors,
    );
  }
}

/// Enumeration for sync batch status
@HiveType(typeId: 26)
enum SyncBatchStatus {
  @HiveField(0)
  @JsonValue('pending')
  pending,
  
  @HiveField(1)
  @JsonValue('running')
  running,
  
  @HiveField(2)
  @JsonValue('completed')
  completed,
  
  @HiveField(3)
  @JsonValue('failed')
  failed,
  
  @HiveField(4)
  @JsonValue('cancelled')
  cancelled,
}

/// Model for sync statistics
@JsonSerializable()
class SyncStats {
  final int totalEntities;
  final int syncedEntities;
  final int pendingEntities;
  final int failedEntities;
  final int conflictedEntities;
  final DateTime? lastSyncAt;
  final Duration? averageSyncTime;
  final Map<String, int> entityTypeCounts;

  SyncStats({
    required this.totalEntities,
    required this.syncedEntities,
    required this.pendingEntities,
    required this.failedEntities,
    required this.conflictedEntities,
    this.lastSyncAt,
    this.averageSyncTime,
    this.entityTypeCounts = const {},
  });

  factory SyncStats.fromJson(Map<String, dynamic> json) =>
      _$SyncStatsFromJson(json);

  Map<String, dynamic> toJson() => _$SyncStatsToJson(this);

  double get syncProgress => totalEntities > 0 ? syncedEntities / totalEntities : 0.0;
  
  bool get hasConflicts => conflictedEntities > 0;
  
  bool get hasPendingSync => pendingEntities > 0 || failedEntities > 0;
}

/// Enumeration for sync error types
@HiveType(typeId: 27)
enum SyncErrorType {
  @HiveField(0)
  @JsonValue('network_error')
  networkError,
  
  @HiveField(1)
  @JsonValue('authentication_error')
  authenticationError,
  
  @HiveField(2)
  @JsonValue('server_error')
  serverError,
  
  @HiveField(3)
  @JsonValue('conflict_error')
  conflictError,
  
  @HiveField(4)
  @JsonValue('validation_error')
  validationError,
  
  @HiveField(5)
  @JsonValue('unknown_error')
  unknownError,
}

/// Model for sync errors
@HiveType(typeId: 28)
@JsonSerializable()
class SyncError {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String operationId;
  
  @HiveField(2)
  final SyncErrorType type;
  
  @HiveField(3)
  final String message;
  
  @HiveField(4)
  final String? entityId;
  
  @HiveField(5)
  final String? entityType;
  
  @HiveField(6)
  final DateTime occurredAt;
  
  @HiveField(7)
  final int retryCount;
  
  @HiveField(8)
  final Map<String, dynamic>? details;

  SyncError({
    required this.id,
    required this.operationId,
    required this.type,
    required this.message,
    this.entityId,
    this.entityType,
    required this.occurredAt,
    this.retryCount = 0,
    this.details,
  });

  factory SyncError.fromJson(Map<String, dynamic> json) =>
      _$SyncErrorFromJson(json);

  Map<String, dynamic> toJson() => _$SyncErrorToJson(this);

  SyncError copyWith({
    String? id,
    String? operationId,
    SyncErrorType? type,
    String? message,
    String? entityId,
    String? entityType,
    DateTime? occurredAt,
    int? retryCount,
    Map<String, dynamic>? details,
  }) {
    return SyncError(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      type: type ?? this.type,
      message: message ?? this.message,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      occurredAt: occurredAt ?? this.occurredAt,
      retryCount: retryCount ?? this.retryCount,
      details: details ?? this.details,
    );
  }
}