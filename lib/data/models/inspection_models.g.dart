// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionItemAdapter extends TypeAdapter<InspectionItem> {
  @override
  final int typeId = 4;

  @override
  InspectionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionItem(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as String,
      isRequired: fields[4] as bool,
      status: fields[5] as InspectionItemStatus,
      notes: fields[6] as String?,
      photoUrls: (fields[7] as List?)?.cast<String>(),
      defectSeverity: fields[8] as DefectSeverity?,
      checkedAt: fields[9] as DateTime?,
      checkedBy: fields[10] as String?,
      documentAttachments: (fields[22] as List?)?.cast<DocumentAttachment>(),
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
      syncStatus: fields[13] as SyncStatus,
      lastSyncAt: fields[14] as DateTime?,
      serverVersion: fields[15] as String?,
      isDeleted: fields[16] as bool,
      conflictData: fields[17] as String?,
      version: fields[18] as int,
      serverUpdatedAt: fields[19] as DateTime?,
      dataHash: fields[20] as String?,
      pendingOperations: (fields[21] as List?)?.cast<SyncOperation>(),
    );
  }

  @override
  void write(BinaryWriter writer, InspectionItem obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isRequired)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.photoUrls)
      ..writeByte(8)
      ..write(obj.defectSeverity)
      ..writeByte(9)
      ..write(obj.checkedAt)
      ..writeByte(10)
      ..write(obj.checkedBy)
      ..writeByte(22)
      ..write(obj.documentAttachments)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.syncStatus)
      ..writeByte(14)
      ..write(obj.lastSyncAt)
      ..writeByte(15)
      ..write(obj.serverVersion)
      ..writeByte(16)
      ..write(obj.isDeleted)
      ..writeByte(17)
      ..write(obj.conflictData)
      ..writeByte(18)
      ..write(obj.version)
      ..writeByte(19)
      ..write(obj.serverUpdatedAt)
      ..writeByte(20)
      ..write(obj.dataHash)
      ..writeByte(21)
      ..write(obj.pendingOperations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 5;

  @override
  Vehicle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vehicle(
      id: fields[0] as String,
      unitNumber: fields[1] as String,
      make: fields[2] as String,
      model: fields[3] as String,
      year: fields[4] as int,
      vinNumber: fields[5] as String,
      plateNumber: fields[6] as String,
      trailerNumber: fields[7] as String?,
      mileage: fields[8] as double?,
      lastInspectionDate: fields[9] as DateTime?,
      isActive: fields[10] as bool,
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
      syncStatus: fields[13] as SyncStatus,
      lastSyncAt: fields[14] as DateTime?,
      serverUpdatedAt: fields[15] as DateTime?,
      version: fields[16] as int,
      dataHash: fields[17] as String?,
      isDeleted: fields[18] as bool,
      pendingOperations: (fields[19] as List).cast<SyncOperation>(),
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.unitNumber)
      ..writeByte(2)
      ..write(obj.make)
      ..writeByte(3)
      ..write(obj.model)
      ..writeByte(4)
      ..write(obj.year)
      ..writeByte(5)
      ..write(obj.vinNumber)
      ..writeByte(6)
      ..write(obj.plateNumber)
      ..writeByte(7)
      ..write(obj.trailerNumber)
      ..writeByte(8)
      ..write(obj.mileage)
      ..writeByte(9)
      ..write(obj.lastInspectionDate)
      ..writeByte(10)
      ..write(obj.isActive)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt)
      ..writeByte(13)
      ..write(obj.syncStatus)
      ..writeByte(14)
      ..write(obj.lastSyncAt)
      ..writeByte(15)
      ..write(obj.serverUpdatedAt)
      ..writeByte(16)
      ..write(obj.version)
      ..writeByte(17)
      ..write(obj.dataHash)
      ..writeByte(18)
      ..write(obj.isDeleted)
      ..writeByte(19)
      ..write(obj.pendingOperations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationInfoAdapter extends TypeAdapter<LocationInfo> {
  @override
  final int typeId = 6;

  @override
  LocationInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationInfo(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      address: fields[2] as String?,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocationInfo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationInfoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InspectionAdapter extends TypeAdapter<Inspection> {
  @override
  final int typeId = 7;

  @override
  Inspection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inspection(
      id: fields[0] as String,
      driverId: fields[1] as String,
      driverName: fields[2] as String,
      vehicle: fields[3] as Vehicle,
      type: fields[4] as InspectionType,
      status: fields[5] as InspectionStatus,
      createdAt: fields[6] as DateTime,
      completedAt: fields[7] as DateTime?,
      location: fields[8] as LocationInfo?,
      items: (fields[9] as List?)?.cast<InspectionItem>(),
      signature: fields[10] as String?,
      overallNotes: fields[11] as String?,
      isSynced: fields[12] as bool,
      lastSyncAt: fields[13] as DateTime?,
      reportPdfPath: fields[14] as String?,
      updatedAt: fields[15] as DateTime?,
      syncStatus: fields[16] as SyncStatus,
      serverVersion: fields[17] as String?,
      isDeleted: fields[18] as bool,
      conflictData: fields[19] as String?,
      version: fields[20] as int,
      serverUpdatedAt: fields[21] as DateTime?,
      dataHash: fields[22] as String?,
      pendingOperations: (fields[23] as List?)?.cast<SyncOperation>(),
    );
  }

  @override
  void write(BinaryWriter writer, Inspection obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.driverId)
      ..writeByte(2)
      ..write(obj.driverName)
      ..writeByte(3)
      ..write(obj.vehicle)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.location)
      ..writeByte(9)
      ..write(obj.items)
      ..writeByte(10)
      ..write(obj.signature)
      ..writeByte(11)
      ..write(obj.overallNotes)
      ..writeByte(12)
      ..write(obj.isSynced)
      ..writeByte(13)
      ..write(obj.lastSyncAt)
      ..writeByte(14)
      ..write(obj.reportPdfPath)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.syncStatus)
      ..writeByte(17)
      ..write(obj.serverVersion)
      ..writeByte(18)
      ..write(obj.isDeleted)
      ..writeByte(19)
      ..write(obj.conflictData)
      ..writeByte(20)
      ..write(obj.version)
      ..writeByte(21)
      ..write(obj.serverUpdatedAt)
      ..writeByte(22)
      ..write(obj.dataHash)
      ..writeByte(23)
      ..write(obj.pendingOperations);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 8;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      cdlNumber: fields[2] as String,
      cdlExpiryDate: fields[3] as DateTime?,
      medicalCertExpiryDate: fields[4] as DateTime?,
      phoneNumber: fields[5] as String?,
      email: fields[6] as String?,
      isActive: fields[7] as bool,
      lastLoginAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.cdlNumber)
      ..writeByte(3)
      ..write(obj.cdlExpiryDate)
      ..writeByte(4)
      ..write(obj.medicalCertExpiryDate)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.lastLoginAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InspectionStatusAdapter extends TypeAdapter<InspectionStatus> {
  @override
  final int typeId = 0;

  @override
  InspectionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InspectionStatus.pending;
      case 1:
        return InspectionStatus.inProgress;
      case 2:
        return InspectionStatus.completed;
      case 3:
        return InspectionStatus.failed;
      default:
        return InspectionStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, InspectionStatus obj) {
    switch (obj) {
      case InspectionStatus.pending:
        writer.writeByte(0);
        break;
      case InspectionStatus.inProgress:
        writer.writeByte(1);
        break;
      case InspectionStatus.completed:
        writer.writeByte(2);
        break;
      case InspectionStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InspectionTypeAdapter extends TypeAdapter<InspectionType> {
  @override
  final int typeId = 1;

  @override
  InspectionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InspectionType.preTrip;
      case 1:
        return InspectionType.postTrip;
      case 2:
        return InspectionType.annual;
      default:
        return InspectionType.preTrip;
    }
  }

  @override
  void write(BinaryWriter writer, InspectionType obj) {
    switch (obj) {
      case InspectionType.preTrip:
        writer.writeByte(0);
        break;
      case InspectionType.postTrip:
        writer.writeByte(1);
        break;
      case InspectionType.annual:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DefectSeverityAdapter extends TypeAdapter<DefectSeverity> {
  @override
  final int typeId = 2;

  @override
  DefectSeverity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DefectSeverity.minor;
      case 1:
        return DefectSeverity.major;
      case 2:
        return DefectSeverity.critical;
      case 3:
        return DefectSeverity.outOfService;
      default:
        return DefectSeverity.minor;
    }
  }

  @override
  void write(BinaryWriter writer, DefectSeverity obj) {
    switch (obj) {
      case DefectSeverity.minor:
        writer.writeByte(0);
        break;
      case DefectSeverity.major:
        writer.writeByte(1);
        break;
      case DefectSeverity.critical:
        writer.writeByte(2);
        break;
      case DefectSeverity.outOfService:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DefectSeverityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InspectionItemStatusAdapter extends TypeAdapter<InspectionItemStatus> {
  @override
  final int typeId = 3;

  @override
  InspectionItemStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return InspectionItemStatus.passed;
      case 1:
        return InspectionItemStatus.failed;
      case 2:
        return InspectionItemStatus.notApplicable;
      default:
        return InspectionItemStatus.passed;
    }
  }

  @override
  void write(BinaryWriter writer, InspectionItemStatus obj) {
    switch (obj) {
      case InspectionItemStatus.passed:
        writer.writeByte(0);
        break;
      case InspectionItemStatus.failed:
        writer.writeByte(1);
        break;
      case InspectionItemStatus.notApplicable:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionItemStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InspectionItem _$InspectionItemFromJson(Map<String, dynamic> json) =>
    InspectionItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      isRequired: json['isRequired'] as bool,
      status:
          $enumDecodeNullable(_$InspectionItemStatusEnumMap, json['status']) ??
              InspectionItemStatus.notApplicable,
      notes: json['notes'] as String?,
      photoUrls: (json['photoUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      defectSeverity:
          $enumDecodeNullable(_$DefectSeverityEnumMap, json['defectSeverity']),
      checkedAt: json['checkedAt'] == null
          ? null
          : DateTime.parse(json['checkedAt'] as String),
      checkedBy: json['checkedBy'] as String?,
      documentAttachments: (json['documentAttachments'] as List<dynamic>?)
          ?.map((e) => DocumentAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
              SyncStatus.pending,
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
      serverVersion: json['serverVersion'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      conflictData: json['conflictData'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      serverUpdatedAt: json['serverUpdatedAt'] == null
          ? null
          : DateTime.parse(json['serverUpdatedAt'] as String),
      dataHash: json['dataHash'] as String?,
      pendingOperations: (json['pendingOperations'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SyncOperationEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$InspectionItemToJson(InspectionItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'isRequired': instance.isRequired,
      'status': _$InspectionItemStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'photoUrls': instance.photoUrls,
      'defectSeverity': _$DefectSeverityEnumMap[instance.defectSeverity],
      'checkedAt': instance.checkedAt?.toIso8601String(),
      'checkedBy': instance.checkedBy,
      'documentAttachments': instance.documentAttachments,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'serverVersion': instance.serverVersion,
      'isDeleted': instance.isDeleted,
      'conflictData': instance.conflictData,
      'version': instance.version,
      'serverUpdatedAt': instance.serverUpdatedAt?.toIso8601String(),
      'dataHash': instance.dataHash,
      'pendingOperations': instance.pendingOperations
          .map((e) => _$SyncOperationEnumMap[e]!)
          .toList(),
    };

const _$InspectionItemStatusEnumMap = {
  InspectionItemStatus.passed: 'passed',
  InspectionItemStatus.failed: 'failed',
  InspectionItemStatus.notApplicable: 'not_applicable',
};

const _$DefectSeverityEnumMap = {
  DefectSeverity.minor: 'minor',
  DefectSeverity.major: 'major',
  DefectSeverity.critical: 'critical',
  DefectSeverity.outOfService: 'out_of_service',
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

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
      id: json['id'] as String,
      unitNumber: json['unitNumber'] as String,
      make: json['make'] as String,
      model: json['model'] as String,
      year: (json['year'] as num).toInt(),
      vinNumber: json['vinNumber'] as String,
      plateNumber: json['plateNumber'] as String,
      trailerNumber: json['trailerNumber'] as String?,
      mileage: (json['mileage'] as num?)?.toDouble(),
      lastInspectionDate: json['lastInspectionDate'] == null
          ? null
          : DateTime.parse(json['lastInspectionDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
              SyncStatus.pending,
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
    );

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      'id': instance.id,
      'unitNumber': instance.unitNumber,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'vinNumber': instance.vinNumber,
      'plateNumber': instance.plateNumber,
      'trailerNumber': instance.trailerNumber,
      'mileage': instance.mileage,
      'lastInspectionDate': instance.lastInspectionDate?.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'serverUpdatedAt': instance.serverUpdatedAt?.toIso8601String(),
      'version': instance.version,
      'dataHash': instance.dataHash,
      'isDeleted': instance.isDeleted,
      'pendingOperations': instance.pendingOperations
          .map((e) => _$SyncOperationEnumMap[e]!)
          .toList(),
    };

LocationInfo _$LocationInfoFromJson(Map<String, dynamic> json) => LocationInfo(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$LocationInfoToJson(LocationInfo instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'timestamp': instance.timestamp.toIso8601String(),
    };

Inspection _$InspectionFromJson(Map<String, dynamic> json) => Inspection(
      id: json['id'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      vehicle: Vehicle.fromJson(json['vehicle'] as Map<String, dynamic>),
      type: $enumDecode(_$InspectionTypeEnumMap, json['type']),
      status: $enumDecodeNullable(_$InspectionStatusEnumMap, json['status']) ??
          InspectionStatus.pending,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      location: json['location'] == null
          ? null
          : LocationInfo.fromJson(json['location'] as Map<String, dynamic>),
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => InspectionItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      signature: json['signature'] as String?,
      overallNotes: json['overallNotes'] as String?,
      isSynced: json['isSynced'] as bool? ?? false,
      lastSyncAt: json['lastSyncAt'] == null
          ? null
          : DateTime.parse(json['lastSyncAt'] as String),
      reportPdfPath: json['reportPdfPath'] as String?,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      syncStatus:
          $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
              SyncStatus.pending,
      serverVersion: json['serverVersion'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      conflictData: json['conflictData'] as String?,
      version: (json['version'] as num?)?.toInt() ?? 1,
      serverUpdatedAt: json['serverUpdatedAt'] == null
          ? null
          : DateTime.parse(json['serverUpdatedAt'] as String),
      dataHash: json['dataHash'] as String?,
      pendingOperations: (json['pendingOperations'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$SyncOperationEnumMap, e))
          .toList(),
    );

Map<String, dynamic> _$InspectionToJson(Inspection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'vehicle': instance.vehicle,
      'type': _$InspectionTypeEnumMap[instance.type]!,
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'location': instance.location,
      'items': instance.items,
      'signature': instance.signature,
      'overallNotes': instance.overallNotes,
      'isSynced': instance.isSynced,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'reportPdfPath': instance.reportPdfPath,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
      'serverVersion': instance.serverVersion,
      'isDeleted': instance.isDeleted,
      'conflictData': instance.conflictData,
      'version': instance.version,
      'serverUpdatedAt': instance.serverUpdatedAt?.toIso8601String(),
      'dataHash': instance.dataHash,
      'pendingOperations': instance.pendingOperations
          .map((e) => _$SyncOperationEnumMap[e]!)
          .toList(),
    };

const _$InspectionTypeEnumMap = {
  InspectionType.preTrip: 'pre_trip',
  InspectionType.postTrip: 'post_trip',
  InspectionType.annual: 'annual',
};

const _$InspectionStatusEnumMap = {
  InspectionStatus.pending: 'pending',
  InspectionStatus.inProgress: 'in_progress',
  InspectionStatus.completed: 'completed',
  InspectionStatus.failed: 'failed',
};

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      cdlNumber: json['cdlNumber'] as String,
      cdlExpiryDate: json['cdlExpiryDate'] == null
          ? null
          : DateTime.parse(json['cdlExpiryDate'] as String),
      medicalCertExpiryDate: json['medicalCertExpiryDate'] == null
          ? null
          : DateTime.parse(json['medicalCertExpiryDate'] as String),
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cdlNumber': instance.cdlNumber,
      'cdlExpiryDate': instance.cdlExpiryDate?.toIso8601String(),
      'medicalCertExpiryDate':
          instance.medicalCertExpiryDate?.toIso8601String(),
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'isActive': instance.isActive,
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
    };
