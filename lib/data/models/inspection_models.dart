import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'sync_models.dart';

part 'inspection_models.g.dart';

/// Enumeration for inspection status
@HiveType(typeId: 0)
enum InspectionStatus {
  @HiveField(0)
  @JsonValue('pending')
  pending,
  
  @HiveField(1)
  @JsonValue('in_progress')
  inProgress,
  
  @HiveField(2)
  @JsonValue('completed')
  completed,
  
  @HiveField(3)
  @JsonValue('failed')
  failed,
}

/// Enumeration for inspection type
@HiveType(typeId: 1)
enum InspectionType {
  @HiveField(0)
  @JsonValue('pre_trip')
  preTrip,
  
  @HiveField(1)
  @JsonValue('post_trip')
  postTrip,
  
  @HiveField(2)
  @JsonValue('annual')
  annual,
}

/// Enumeration for defect severity
@HiveType(typeId: 2)
enum DefectSeverity {
  @HiveField(0)
  @JsonValue('minor')
  minor,
  
  @HiveField(1)
  @JsonValue('major')
  major,
  
  @HiveField(2)
  @JsonValue('critical')
  critical,
  
  @HiveField(3)
  @JsonValue('out_of_service')
  outOfService,
}

/// Enumeration for inspection item status
@HiveType(typeId: 3)
enum InspectionItemStatus {
  @HiveField(0)
  @JsonValue('passed')
  passed,
  
  @HiveField(1)
  @JsonValue('failed')
  failed,
  
  @HiveField(2)
  @JsonValue('not_applicable')
  notApplicable,
}

/// Model for individual inspection item
@HiveType(typeId: 4)
@JsonSerializable()
class InspectionItem with SyncableMixin {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String category;
  
  @HiveField(4)
  final bool isRequired;
  
  @HiveField(5)
  InspectionItemStatus status;
  
  @HiveField(6)
  String? notes;
  
  @HiveField(7)
  List<String> photoUrls;
  
  @HiveField(8)
  DefectSeverity? defectSeverity;
  
  @HiveField(9)
  DateTime? checkedAt;
  
  @HiveField(10)
  String? checkedBy;

  // Sync fields
  @HiveField(11)
  @override
  final DateTime createdAt;
  
  @HiveField(12)
  @override
  final DateTime updatedAt;
  
  @HiveField(13)
  @override
  final SyncStatus syncStatus;
  
  @HiveField(14)
  @override
  final DateTime? lastSyncAt;
  
  @HiveField(15)
  @override
  final String? serverVersion;
  
  @HiveField(16)
  @override
  final bool isDeleted;
  
  @HiveField(17)
  @override
  final String? conflictData;
  
  @HiveField(18)
  @override
  final int version;
  
  @HiveField(19)
  @override
  final DateTime? serverUpdatedAt;
  
  @HiveField(20)
  @override
  final String? dataHash;
  
  @HiveField(21)
  @override
  final List<SyncOperation> pendingOperations;

  InspectionItem({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isRequired,
    this.status = InspectionItemStatus.notApplicable,
    this.notes,
    List<String>? photoUrls,
    this.defectSeverity,
    this.checkedAt,
    this.checkedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncAt,
    this.serverVersion,
    this.isDeleted = false,
    this.conflictData,
    this.version = 1,
    this.serverUpdatedAt,
    this.dataHash,
    List<SyncOperation>? pendingOperations,
  }) : photoUrls = photoUrls ?? [],
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       pendingOperations = pendingOperations ?? [];

  factory InspectionItem.fromJson(Map<String, dynamic> json) =>
      _$InspectionItemFromJson(json);

  Map<String, dynamic> toJson() => _$InspectionItemToJson(this);

  InspectionItem copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    bool? isRequired,
    InspectionItemStatus? status,
    String? notes,
    List<String>? photoUrls,
    DefectSeverity? defectSeverity,
    DateTime? checkedAt,
    String? checkedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncAt,
    String? serverVersion,
    bool? isDeleted,
    String? conflictData,
    int? version,
    DateTime? serverUpdatedAt,
    String? dataHash,
    List<SyncOperation>? pendingOperations,
  }) {
    return InspectionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      isRequired: isRequired ?? this.isRequired,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      photoUrls: photoUrls ?? this.photoUrls,
      defectSeverity: defectSeverity ?? this.defectSeverity,
      checkedAt: checkedAt ?? this.checkedAt,
      checkedBy: checkedBy ?? this.checkedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      serverVersion: serverVersion ?? this.serverVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      conflictData: conflictData ?? this.conflictData,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      dataHash: dataHash ?? this.dataHash,
      pendingOperations: pendingOperations ?? this.pendingOperations,
    );
  }
}

/// Model for vehicle information
@HiveType(typeId: 5)
@JsonSerializable()
class Vehicle with SyncableMixin {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String unitNumber;
  
  @HiveField(2)
  final String make;
  
  @HiveField(3)
  final String model;
  
  @HiveField(4)
  final int year;
  
  @HiveField(5)
  final String vinNumber;
  
  @HiveField(6)
  final String plateNumber;
  
  @HiveField(7)
  final String? trailerNumber;
  
  @HiveField(8)
  final double? mileage;
  
  @HiveField(9)
  final DateTime? lastInspectionDate;
  
  @HiveField(10)
  final bool isActive;
  
  // Sync-related fields
  @HiveField(11)
  final DateTime createdAt;
  
  @HiveField(12)
  final DateTime updatedAt;
  
  @HiveField(13)
  final SyncStatus syncStatus;
  
  @HiveField(14)
  final DateTime? lastSyncAt;
  
  @HiveField(15)
  final DateTime? serverUpdatedAt;
  
  @HiveField(16)
  final int version;
  
  @HiveField(17)
  final String? dataHash;
  
  @HiveField(18)
  final bool isDeleted;
  
  @HiveField(19)
  final List<SyncOperation> pendingOperations;

  Vehicle({
    required this.id,
    required this.unitNumber,
    required this.make,
    required this.model,
    required this.year,
    required this.vinNumber,
    required this.plateNumber,
    this.trailerNumber,
    this.mileage,
    this.lastInspectionDate,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncAt,
    this.serverUpdatedAt,
    this.version = 1,
    this.dataHash,
    this.isDeleted = false,
    this.pendingOperations = const [],
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleToJson(this);

  Vehicle copyWith({
    String? id,
    String? unitNumber,
    String? make,
    String? model,
    int? year,
    String? vinNumber,
    String? plateNumber,
    String? trailerNumber,
    double? mileage,
    DateTime? lastInspectionDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncAt,
    DateTime? serverUpdatedAt,
    int? version,
    String? dataHash,
    bool? isDeleted,
    List<SyncOperation>? pendingOperations,
  }) {
    return Vehicle(
      id: id ?? this.id,
      unitNumber: unitNumber ?? this.unitNumber,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vinNumber: vinNumber ?? this.vinNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      trailerNumber: trailerNumber ?? this.trailerNumber,
      mileage: mileage ?? this.mileage,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      version: version ?? this.version,
      dataHash: dataHash ?? this.dataHash,
      isDeleted: isDeleted ?? this.isDeleted,
      pendingOperations: pendingOperations ?? this.pendingOperations,
    );
  }
}

/// Model for location information
@HiveType(typeId: 6)
@JsonSerializable()
class LocationInfo {
  @HiveField(0)
  final double latitude;
  
  @HiveField(1)
  final double longitude;
  
  @HiveField(2)
  final String? address;
  
  @HiveField(3)
  final DateTime timestamp;

  LocationInfo({
    required this.latitude,
    required this.longitude,
    this.address,
    required this.timestamp,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) =>
      _$LocationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LocationInfoToJson(this);
}

/// Main inspection model
@HiveType(typeId: 7)
@JsonSerializable()
class Inspection with SyncableMixin {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String driverId;
  
  @HiveField(2)
  final String driverName;
  
  @HiveField(3)
  final Vehicle vehicle;
  
  @HiveField(4)
  final InspectionType type;
  
  @HiveField(5)
  InspectionStatus status;
  
  @HiveField(6)
  final DateTime createdAt;
  
  @HiveField(7)
  DateTime? completedAt;
  
  @HiveField(8)
  final LocationInfo? location;
  
  @HiveField(9)
  List<InspectionItem> items;
  
  @HiveField(10)
  String? signature;
  
  @HiveField(11)
  String? overallNotes;
  
  @HiveField(12)
  bool isSynced;
  
  @HiveField(13)
  DateTime? lastSyncAt;
  
  @HiveField(14)
  String? reportPdfPath;

  // Sync fields
  @HiveField(15)
  @override
  final DateTime updatedAt;
  
  @HiveField(16)
  @override
  final SyncStatus syncStatus;
  
  @HiveField(17)
  @override
  final String? serverVersion;
  
  @HiveField(18)
  @override
  final bool isDeleted;
  
  @HiveField(19)
  @override
  final String? conflictData;
  
  @HiveField(20)
  @override
  final int version;
  
  @HiveField(21)
  @override
  final DateTime? serverUpdatedAt;
  
  @HiveField(22)
  @override
  final String? dataHash;
  
  @HiveField(23)
  @override
  final List<SyncOperation> pendingOperations;

  Inspection({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.vehicle,
    required this.type,
    this.status = InspectionStatus.pending,
    required this.createdAt,
    this.completedAt,
    this.location,
    List<InspectionItem>? items,
    this.signature,
    this.overallNotes,
    this.isSynced = false,
    this.lastSyncAt,
    this.reportPdfPath,
    DateTime? updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.serverVersion,
    this.isDeleted = false,
    this.conflictData,
    this.version = 1,
    this.serverUpdatedAt,
    this.dataHash,
    List<SyncOperation>? pendingOperations,
  }) : items = items ?? [],
       updatedAt = updatedAt ?? DateTime.now(),
       pendingOperations = pendingOperations ?? [];

  factory Inspection.fromJson(Map<String, dynamic> json) =>
      _$InspectionFromJson(json);

  Map<String, dynamic> toJson() => _$InspectionToJson(this);

  /// Get inspection progress as percentage (0-100)
  double get progressPercentage {
    if (items.isEmpty) return 0.0;
    
    // Since all items now have a status by default, progress is always 100%
    // But we can calculate based on items that have been explicitly checked
    final checkedItems = items.where((item) => 
        item.checkedAt != null).length;
    
    return (checkedItems / items.length) * 100;
  }
  
  /// Get count of failed items
  int get failedItemsCount {
    return items.where((item) => 
        item.status == InspectionItemStatus.failed).length;
  }
  
  /// Get count of passed items
  int get passedItemsCount {
    return items.where((item) => 
        item.status == InspectionItemStatus.passed).length;
  }
  
  /// Check if inspection has any critical defects
  bool get hasCriticalDefects {
    return items.any((item) => 
        item.defectSeverity == DefectSeverity.critical ||
        item.defectSeverity == DefectSeverity.outOfService);
  }
  
  /// Check if inspection is complete (all required items checked)
  bool get isComplete {
    final requiredItems = items.where((item) => item.isRequired);
    return requiredItems.every((item) => 
        item.checkedAt != null);
  }

  Inspection copyWith({
    String? id,
    String? driverId,
    String? driverName,
    Vehicle? vehicle,
    InspectionType? type,
    InspectionStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    LocationInfo? location,
    List<InspectionItem>? items,
    String? signature,
    String? overallNotes,
    bool? isSynced,
    DateTime? lastSyncAt,
    String? reportPdfPath,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    String? serverVersion,
    bool? isDeleted,
    String? conflictData,
    int? version,
    DateTime? serverUpdatedAt,
    String? dataHash,
    List<SyncOperation>? pendingOperations,
  }) {
    return Inspection(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      vehicle: vehicle ?? this.vehicle,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      location: location ?? this.location,
      items: items ?? this.items,
      signature: signature ?? this.signature,
      overallNotes: overallNotes ?? this.overallNotes,
      isSynced: isSynced ?? this.isSynced,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      reportPdfPath: reportPdfPath ?? this.reportPdfPath,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      serverVersion: serverVersion ?? this.serverVersion,
      isDeleted: isDeleted ?? this.isDeleted,
      conflictData: conflictData ?? this.conflictData,
      version: version ?? this.version,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      dataHash: dataHash ?? this.dataHash,
      pendingOperations: pendingOperations ?? this.pendingOperations,
    );
  }
}

/// Model for user information
@HiveType(typeId: 8)
@JsonSerializable()
class User {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String cdlNumber;
  
  @HiveField(3)
  final DateTime? cdlExpiryDate;
  
  @HiveField(4)
  final DateTime? medicalCertExpiryDate;
  
  @HiveField(5)
  final String? phoneNumber;
  
  @HiveField(6)
  final String? email;
  
  @HiveField(7)
  final bool isActive;
  
  @HiveField(8)
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.cdlNumber,
    this.cdlExpiryDate,
    this.medicalCertExpiryDate,
    this.phoneNumber,
    this.email,
    this.isActive = true,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) =>
      _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  /// Check if CDL is expiring soon (within 30 days)
  bool get isCdlExpiringSoon {
    if (cdlExpiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = cdlExpiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }
  
  /// Check if medical certificate is expiring soon (within 30 days)
  bool get isMedicalCertExpiringSoon {
    if (medicalCertExpiryDate == null) return false;
    final now = DateTime.now();
    final daysUntilExpiry = medicalCertExpiryDate!.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  User copyWith({
    String? id,
    String? name,
    String? cdlNumber,
    DateTime? cdlExpiryDate,
    DateTime? medicalCertExpiryDate,
    String? phoneNumber,
    String? email,
    bool? isActive,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      cdlNumber: cdlNumber ?? this.cdlNumber,
      cdlExpiryDate: cdlExpiryDate ?? this.cdlExpiryDate,
      medicalCertExpiryDate: medicalCertExpiryDate ?? this.medicalCertExpiryDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}