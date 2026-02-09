// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TruckLocation _$TruckLocationFromJson(Map<String, dynamic> json) =>
    TruckLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: $enumDecode(_$LocationTypeEnumMap, json['type']),
      description: json['description'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      phoneNumber: json['phoneNumber'] as String?,
      website: json['website'] as String?,
      isOpen24Hours: json['isOpen24Hours'] as bool? ?? false,
      operatingHours: json['operatingHours'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TruckLocationToJson(TruckLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': _$LocationTypeEnumMap[instance.type]!,
      'description': instance.description,
      'amenities': instance.amenities,
      'phoneNumber': instance.phoneNumber,
      'website': instance.website,
      'isOpen24Hours': instance.isOpen24Hours,
      'operatingHours': instance.operatingHours,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$LocationTypeEnumMap = {
  LocationType.restArea: 'restArea',
  LocationType.truckStop: 'truckStop',
  LocationType.gasStation: 'gasStation',
};

LocationReview _$LocationReviewFromJson(Map<String, dynamic> json) =>
    LocationReview(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LocationReviewToJson(LocationReview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locationId': instance.locationId,
      'userId': instance.userId,
      'userName': instance.userName,
      'rating': instance.rating,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

ParkingStatusUpdate _$ParkingStatusUpdateFromJson(Map<String, dynamic> json) =>
    ParkingStatusUpdate(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      status: $enumDecode(_$ParkingStatusEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$ParkingStatusUpdateToJson(
        ParkingStatusUpdate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locationId': instance.locationId,
      'userId': instance.userId,
      'userName': instance.userName,
      'status': _$ParkingStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'notes': instance.notes,
    };

const _$ParkingStatusEnumMap = {
  ParkingStatus.available: 'available',
  ParkingStatus.fewSpotsLeft: 'fewSpotsLeft',
  ParkingStatus.full: 'full',
};

FavoriteLocation _$FavoriteLocationFromJson(Map<String, dynamic> json) =>
    FavoriteLocation(
      id: json['id'] as String,
      locationId: json['locationId'] as String,
      userId: json['userId'] as String,
      addedAt: DateTime.parse(json['addedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$FavoriteLocationToJson(FavoriteLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'locationId': instance.locationId,
      'userId': instance.userId,
      'addedAt': instance.addedAt.toIso8601String(),
      'notes': instance.notes,
    };

LocationStats _$LocationStatsFromJson(Map<String, dynamic> json) =>
    LocationStats(
      locationId: json['locationId'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      currentParkingStatus: $enumDecodeNullable(
          _$ParkingStatusEnumMap, json['currentParkingStatus']),
      lastParkingUpdate: json['lastParkingUpdate'] == null
          ? null
          : DateTime.parse(json['lastParkingUpdate'] as String),
      favoriteCount: (json['favoriteCount'] as num).toInt(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$LocationStatsToJson(LocationStats instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'currentParkingStatus':
          _$ParkingStatusEnumMap[instance.currentParkingStatus],
      'lastParkingUpdate': instance.lastParkingUpdate?.toIso8601String(),
      'favoriteCount': instance.favoriteCount,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
