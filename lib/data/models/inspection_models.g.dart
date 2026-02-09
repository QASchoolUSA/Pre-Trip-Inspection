// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_models.dart';

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
      isDeleted: json['isDeleted'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$InspectionToJson(Inspection instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driverId': instance.driverId,
      'driverName': instance.driverName,
      'vehicle': instance.vehicle.toJson(),
      'type': _$InspectionTypeEnumMap[instance.type]!,
      'status': _$InspectionStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'location': instance.location?.toJson(),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'signature': instance.signature,
      'overallNotes': instance.overallNotes,
      'isSynced': instance.isSynced,
      'lastSyncAt': instance.lastSyncAt?.toIso8601String(),
      'reportPdfPath': instance.reportPdfPath,
      'isDeleted': instance.isDeleted,
      'updatedAt': instance.updatedAt.toIso8601String(),
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
      role: json['role'] as String?,
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
      'role': instance.role,
    };
