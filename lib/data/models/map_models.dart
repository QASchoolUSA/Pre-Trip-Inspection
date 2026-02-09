
import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';

part 'map_models.g.dart';

enum LocationType {
  @HiveField(0)
  restArea,
  @HiveField(1)
  truckStop,
  @HiveField(2)
  gasStation,
}

enum ParkingStatus {
  @HiveField(0)
  available,
  @HiveField(1)
  fewSpotsLeft,
  @HiveField(2)
  full,
}

@JsonSerializable()
class TruckLocation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String address;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final LocationType type;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final List<String> amenities;

  @HiveField(8)
  final String? phoneNumber;

  @HiveField(9)
  final String? website;

  @HiveField(10)
  final bool isOpen24Hours;

  @HiveField(11)
  final String? operatingHours;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime updatedAt;

  const TruckLocation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.description,
    this.amenities = const [],
    this.phoneNumber,
    this.website,
    this.isOpen24Hours = false,
    this.operatingHours,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TruckLocation.fromJson(Map<String, dynamic> json) =>
      _$TruckLocationFromJson(json);

  Map<String, dynamic> toJson() => _$TruckLocationToJson(this);

  TruckLocation copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    LocationType? type,
    String? description,
    List<String>? amenities,
    String? phoneNumber,
    String? website,
    bool? isOpen24Hours,
    String? operatingHours,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TruckLocation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      description: description ?? this.description,
      amenities: amenities ?? this.amenities,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      isOpen24Hours: isOpen24Hours ?? this.isOpen24Hours,
      operatingHours: operatingHours ?? this.operatingHours,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class LocationReview {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String locationId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String userName;

  @HiveField(4)
  final int rating; // 1-5 stars

  @HiveField(5)
  final String comment;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  const LocationReview({
    required this.id,
    required this.locationId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LocationReview.fromJson(Map<String, dynamic> json) =>
      _$LocationReviewFromJson(json);

  Map<String, dynamic> toJson() => _$LocationReviewToJson(this);

  LocationReview copyWith({
    String? id,
    String? locationId,
    String? userId,
    String? userName,
    int? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationReview(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class ParkingStatusUpdate {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String locationId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String userName;

  @HiveField(4)
  final ParkingStatus status;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String? notes;

  const ParkingStatusUpdate({
    required this.id,
    required this.locationId,
    required this.userId,
    required this.userName,
    required this.status,
    required this.timestamp,
    this.notes,
  });

  factory ParkingStatusUpdate.fromJson(Map<String, dynamic> json) =>
      _$ParkingStatusUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$ParkingStatusUpdateToJson(this);

  ParkingStatusUpdate copyWith({
    String? id,
    String? locationId,
    String? userId,
    String? userName,
    ParkingStatus? status,
    DateTime? timestamp,
    String? notes,
  }) {
    return ParkingStatusUpdate(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }
}

@JsonSerializable()
class FavoriteLocation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String locationId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final DateTime addedAt;

  @HiveField(4)
  final String? notes;

  const FavoriteLocation({
    required this.id,
    required this.locationId,
    required this.userId,
    required this.addedAt,
    this.notes,
  });

  factory FavoriteLocation.fromJson(Map<String, dynamic> json) =>
      _$FavoriteLocationFromJson(json);

  Map<String, dynamic> toJson() => _$FavoriteLocationToJson(this);

  FavoriteLocation copyWith({
    String? id,
    String? locationId,
    String? userId,
    DateTime? addedAt,
    String? notes,
  }) {
    return FavoriteLocation(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      addedAt: addedAt ?? this.addedAt,
      notes: notes ?? this.notes,
    );
  }
}

@JsonSerializable()
class LocationStats {
  @HiveField(0)
  final String locationId;

  @HiveField(1)
  final double averageRating;

  @HiveField(2)
  final int totalReviews;

  @HiveField(3)
  final ParkingStatus? currentParkingStatus;

  @HiveField(4)
  final DateTime? lastParkingUpdate;

  @HiveField(5)
  final int favoriteCount;

  @HiveField(6)
  final DateTime updatedAt;

  const LocationStats({
    required this.locationId,
    required this.averageRating,
    required this.totalReviews,
    this.currentParkingStatus,
    this.lastParkingUpdate,
    required this.favoriteCount,
    required this.updatedAt,
  });

  factory LocationStats.fromJson(Map<String, dynamic> json) =>
      _$LocationStatsFromJson(json);

  Map<String, dynamic> toJson() => _$LocationStatsToJson(this);

  LocationStats copyWith({
    String? locationId,
    double? averageRating,
    int? totalReviews,
    ParkingStatus? currentParkingStatus,
    DateTime? lastParkingUpdate,
    int? favoriteCount,
    DateTime? updatedAt,
  }) {
    return LocationStats(
      locationId: locationId ?? this.locationId,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      currentParkingStatus: currentParkingStatus ?? this.currentParkingStatus,
      lastParkingUpdate: lastParkingUpdate ?? this.lastParkingUpdate,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}