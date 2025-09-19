// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncMetadataAdapter extends TypeAdapter<SyncMetadata> {
  @override
  final int typeId = 22;

  @override
  SyncMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncMetadata(
      entityId: fields[0] as String,
      entityType: fields[1] as String,
      status: fields[2] as SyncStatus,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime,
      lastSyncAt: fields[5] as DateTime?,
      serverUpdatedAt: fields[6] as DateTime?,
      version: fields[7] as int,
      dataHash: fields[8] as String?,
      isDeleted: fields[9] as bool,
      pendingOperations: (fields[10] as List).cast<SyncOperation>(),
      errorMessage: fields[11] as String?,
      retryCount: fields[12] as int,
      nextRetryAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncMetadata obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.entityId)
      ..writeByte(1)
      ..write(obj.entityType)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.lastSyncAt)
      ..writeByte(6)
      ..write(obj.serverUpdatedAt)
      ..writeByte(7)
      ..write(obj.version)
      ..writeByte(8)
      ..write(obj.dataHash)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10)
      ..write(obj.pendingOperations)
      ..writeByte(11)
      ..write(obj.errorMessage)
      ..writeByte(12)
      ..write(obj.retryCount)
      ..writeByte(13)
      ..write(obj.nextRetryAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncConflictAdapter extends TypeAdapter<SyncConflict> {
  @override
  final int typeId = 23;

  @override
  SyncConflict read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncConflict(
      id: fields[0] as String,
      entityId: fields[1] as String,
      entityType: fields[2] as String,
      localData: (fields[3] as Map).cast<String, dynamic>(),
      serverData: (fields[4] as Map).cast<String, dynamic>(),
      detectedAt: fields[5] as DateTime,
      resolution: fields[6] as ConflictResolution?,
      resolvedAt: fields[7] as DateTime?,
      resolvedBy: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SyncConflict obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.entityId)
      ..writeByte(2)
      ..write(obj.entityType)
      ..writeByte(3)
      ..write(obj.localData)
      ..writeByte(4)
      ..write(obj.serverData)
      ..writeByte(5)
      ..write(obj.detectedAt)
      ..writeByte(6)
      ..write(obj.resolution)
      ..writeByte(7)
      ..write(obj.resolvedAt)
      ..writeByte(8)
      ..write(obj.resolvedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncConflictAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncBatchAdapter extends TypeAdapter<SyncBatch> {
  @override
  final int typeId = 25;

  @override
  SyncBatch read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncBatch(
      id: fields[0] as String,
      startedAt: fields[1] as DateTime,
      completedAt: fields[2] as DateTime?,
      status: fields[3] as SyncBatchStatus,
      entityIds: (fields[4] as List).cast<String>(),
      totalEntities: fields[5] as int,
      processedEntities: fields[6] as int,
      successfulEntities: fields[7] as int,
      failedEntities: fields[8] as int,
      errors: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SyncBatch obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.startedAt)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.entityIds)
      ..writeByte(5)
      ..write(obj.totalEntities)
      ..writeByte(6)
      ..write(obj.processedEntities)
      ..writeByte(7)
      ..write(obj.successfulEntities)
      ..writeByte(8)
      ..write(obj.failedEntities)
      ..writeByte(9)
      ..write(obj.errors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncBatchAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncErrorAdapter extends TypeAdapter<SyncError> {
  @override
  final int typeId = 28;

  @override
  SyncError read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncError(
      id: fields[0] as String,
      operationId: fields[1] as String,
      type: fields[2] as SyncErrorType,
      message: fields[3] as String,
      entityId: fields[4] as String?,
      entityType: fields[5] as String?,
      occurredAt: fields[6] as DateTime,
      retryCount: fields[7] as int,
      details: (fields[8] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SyncError obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.operationId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.entityId)
      ..writeByte(5)
      ..write(obj.entityType)
      ..writeByte(6)
      ..write(obj.occurredAt)
      ..writeByte(7)
      ..write(obj.retryCount)
      ..writeByte(8)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncErrorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncStatusAdapter extends TypeAdapter<SyncStatus> {
  @override
  final int typeId = 20;

  @override
  SyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncStatus.pending;
      case 1:
        return SyncStatus.syncing;
      case 2:
        return SyncStatus.synced;
      case 3:
        return SyncStatus.failed;
      case 4:
        return SyncStatus.conflict;
      default:
        return SyncStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SyncStatus obj) {
    switch (obj) {
      case SyncStatus.pending:
        writer.writeByte(0);
        break;
      case SyncStatus.syncing:
        writer.writeByte(1);
        break;
      case SyncStatus.synced:
        writer.writeByte(2);
        break;
      case SyncStatus.failed:
        writer.writeByte(3);
        break;
      case SyncStatus.conflict:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncOperationAdapter extends TypeAdapter<SyncOperation> {
  @override
  final int typeId = 21;

  @override
  SyncOperation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncOperation.create;
      case 1:
        return SyncOperation.update;
      case 2:
        return SyncOperation.delete;
      default:
        return SyncOperation.create;
    }
  }

  @override
  void write(BinaryWriter writer, SyncOperation obj) {
    switch (obj) {
      case SyncOperation.create:
        writer.writeByte(0);
        break;
      case SyncOperation.update:
        writer.writeByte(1);
        break;
      case SyncOperation.delete:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConflictResolutionAdapter extends TypeAdapter<ConflictResolution> {
  @override
  final int typeId = 24;

  @override
  ConflictResolution read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ConflictResolution.useLocal;
      case 1:
        return ConflictResolution.useServer;
      case 2:
        return ConflictResolution.merge;
      case 3:
        return ConflictResolution.manual;
      default:
        return ConflictResolution.useLocal;
    }
  }

  @override
  void write(BinaryWriter writer, ConflictResolution obj) {
    switch (obj) {
      case ConflictResolution.useLocal:
        writer.writeByte(0);
        break;
      case ConflictResolution.useServer:
        writer.writeByte(1);
        break;
      case ConflictResolution.merge:
        writer.writeByte(2);
        break;
      case ConflictResolution.manual:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConflictResolutionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncBatchStatusAdapter extends TypeAdapter<SyncBatchStatus> {
  @override
  final int typeId = 26;

  @override
  SyncBatchStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncBatchStatus.pending;
      case 1:
        return SyncBatchStatus.running;
      case 2:
        return SyncBatchStatus.completed;
      case 3:
        return SyncBatchStatus.failed;
      case 4:
        return SyncBatchStatus.cancelled;
      default:
        return SyncBatchStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SyncBatchStatus obj) {
    switch (obj) {
      case SyncBatchStatus.pending:
        writer.writeByte(0);
        break;
      case SyncBatchStatus.running:
        writer.writeByte(1);
        break;
      case SyncBatchStatus.completed:
        writer.writeByte(2);
        break;
      case SyncBatchStatus.failed:
        writer.writeByte(3);
        break;
      case SyncBatchStatus.cancelled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncBatchStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncErrorTypeAdapter extends TypeAdapter<SyncErrorType> {
  @override
  final int typeId = 27;

  @override
  SyncErrorType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncErrorType.networkError;
      case 1:
        return SyncErrorType.authenticationError;
      case 2:
        return SyncErrorType.serverError;
      case 3:
        return SyncErrorType.conflictError;
      case 4:
        return SyncErrorType.validationError;
      case 5:
        return SyncErrorType.unknownError;
      default:
        return SyncErrorType.networkError;
    }
  }

  @override
  void write(BinaryWriter writer, SyncErrorType obj) {
    switch (obj) {
      case SyncErrorType.networkError:
        writer.writeByte(0);
        break;
      case SyncErrorType.authenticationError:
        writer.writeByte(1);
        break;
      case SyncErrorType.serverError:
        writer.writeByte(2);
        break;
      case SyncErrorType.conflictError:
        writer.writeByte(3);
        break;
      case SyncErrorType.validationError:
        writer.writeByte(4);
        break;
      case SyncErrorType.unknownError:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncErrorTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncMetadata _$SyncMetadataFromJson(Map<String, dynamic> json) => SyncMetadata(
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      status: $enumDecode(_$SyncStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
      serverUpdatedAt: json['serverUpdatedAt'] == null
          ? null
          : DateTime.parse(json['serverUpdatedAt'] as String),
      version: (json['version'] as num?)?.toInt() ?? 1,
      dataHash: json['dataHash'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      pendingOperations: (json['pendingOperations'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$SyncOperationEnumMap, e))
              .toList() ??
          const [],
      errorMessage: json['errorMessage'] as String?,
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      nextRetryAt: json['nextRetryAt'] == null
          ? null
          : DateTime.parse(json['nextRetryAt'] as String),
    );

Map<String, dynamic> _$SyncMetadataToJson(SyncMetadata instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'status': _$SyncStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'serverUpdatedAt': instance.serverUpdatedAt?.toIso8601String(),
      'version': instance.version,
      'dataHash': instance.dataHash,
      'isDeleted': instance.isDeleted,
      'pendingOperations': instance.pendingOperations
          .map((e) => _$SyncOperationEnumMap[e]!)
          .toList(),
      'errorMessage': instance.errorMessage,
      'retryCount': instance.retryCount,
      'nextRetryAt': instance.nextRetryAt?.toIso8601String(),
    };

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.synced: 'synced',
  SyncStatus.failed: 'failed',
  SyncStatus.conflict: 'conflict',
};

const _$SyncOperationEnumMap = {
  SyncOperation.create: 'create',
  SyncOperation.update: 'update',
  SyncOperation.delete: 'delete',
};

SyncConflict _$SyncConflictFromJson(Map<String, dynamic> json) => SyncConflict(
      id: json['id'] as String,
      entityId: json['entityId'] as String,
      entityType: json['entityType'] as String,
      localData: json['localData'] as Map<String, dynamic>,
      serverData: json['serverData'] as Map<String, dynamic>,
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      resolution:
          $enumDecodeNullable(_$ConflictResolutionEnumMap, json['resolution']),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedBy: json['resolvedBy'] as String?,
    );

Map<String, dynamic> _$SyncConflictToJson(SyncConflict instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'localData': instance.localData,
      'serverData': instance.serverData,
      'detectedAt': instance.detectedAt.toIso8601String(),
      'resolution': _$ConflictResolutionEnumMap[instance.resolution],
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedBy': instance.resolvedBy,
    };

const _$ConflictResolutionEnumMap = {
  ConflictResolution.useLocal: 'use_local',
  ConflictResolution.useServer: 'use_server',
  ConflictResolution.merge: 'merge',
  ConflictResolution.manual: 'manual',
};

SyncBatch _$SyncBatchFromJson(Map<String, dynamic> json) => SyncBatch(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      status: $enumDecode(_$SyncBatchStatusEnumMap, json['status']),
      entityIds:
          (json['entityIds'] as List<dynamic>).map((e) => e as String).toList(),
      totalEntities: (json['totalEntities'] as num).toInt(),
      processedEntities: (json['processedEntities'] as num?)?.toInt() ?? 0,
      successfulEntities: (json['successfulEntities'] as num?)?.toInt() ?? 0,
      failedEntities: (json['failedEntities'] as num?)?.toInt() ?? 0,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SyncBatchToJson(SyncBatch instance) => <String, dynamic>{
      'id': instance.id,
      'startedAt': instance.startedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'status': _$SyncBatchStatusEnumMap[instance.status]!,
      'entityIds': instance.entityIds,
      'totalEntities': instance.totalEntities,
      'processedEntities': instance.processedEntities,
      'successfulEntities': instance.successfulEntities,
      'failedEntities': instance.failedEntities,
      'errors': instance.errors,
    };

const _$SyncBatchStatusEnumMap = {
  SyncBatchStatus.pending: 'pending',
  SyncBatchStatus.running: 'running',
  SyncBatchStatus.completed: 'completed',
  SyncBatchStatus.failed: 'failed',
  SyncBatchStatus.cancelled: 'cancelled',
};

SyncStats _$SyncStatsFromJson(Map<String, dynamic> json) => SyncStats(
      totalEntities: (json['totalEntities'] as num).toInt(),
      syncedEntities: (json['syncedEntities'] as num).toInt(),
      pendingEntities: (json['pendingEntities'] as num).toInt(),
      failedEntities: (json['failedEntities'] as num).toInt(),
      conflictedEntities: (json['conflictedEntities'] as num).toInt(),
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
      averageSyncTime: json['averageSyncTime'] == null
          ? null
          : Duration(microseconds: (json['averageSyncTime'] as num).toInt()),
      entityTypeCounts:
          (json['entityTypeCounts'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, (e as num).toInt()),
              ) ??
              const {},
    );

Map<String, dynamic> _$SyncStatsToJson(SyncStats instance) => <String, dynamic>{
      'totalEntities': instance.totalEntities,
      'syncedEntities': instance.syncedEntities,
      'pendingEntities': instance.pendingEntities,
      'failedEntities': instance.failedEntities,
      'conflictedEntities': instance.conflictedEntities,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'averageSyncTime': instance.averageSyncTime?.inMicroseconds,
      'entityTypeCounts': instance.entityTypeCounts,
    };

SyncError _$SyncErrorFromJson(Map<String, dynamic> json) => SyncError(
      id: json['id'] as String,
      operationId: json['operationId'] as String,
      type: $enumDecode(_$SyncErrorTypeEnumMap, json['type']),
      message: json['message'] as String,
      entityId: json['entityId'] as String?,
      entityType: json['entityType'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      retryCount: (json['retryCount'] as num?)?.toInt() ?? 0,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$SyncErrorToJson(SyncError instance) => <String, dynamic>{
      'id': instance.id,
      'operationId': instance.operationId,
      'type': _$SyncErrorTypeEnumMap[instance.type]!,
      'message': instance.message,
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'occurredAt': instance.occurredAt.toIso8601String(),
      'retryCount': instance.retryCount,
      'details': instance.details,
    };

const _$SyncErrorTypeEnumMap = {
  SyncErrorType.networkError: 'network_error',
  SyncErrorType.authenticationError: 'authentication_error',
  SyncErrorType.serverError: 'server_error',
  SyncErrorType.conflictError: 'conflict_error',
  SyncErrorType.validationError: 'validation_error',
  SyncErrorType.unknownError: 'unknown_error',
};
