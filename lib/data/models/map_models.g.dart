// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TruckLocationAdapter extends TypeAdapter<TruckLocation> {
  @override
  final int typeId = 10;

  @override
  TruckLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TruckLocation(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      type: fields[5] as LocationType,
      description: fields[6] as String?,
      amenities: (fields[7] as List).cast<String>(),
      phoneNumber: fields[8] as String?,
      website: fields[9] as String?,
      isOpen24Hours: fields[10] as bool,
      operatingHours: fields[11] as String?,
      createdAt: fields[12] as DateTime,
      updatedAt: fields[13] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, TruckLocation obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.amenities)
      ..writeByte(8)
      ..write(obj.phoneNumber)
      ..writeByte(9)
      ..write(obj.website)
      ..writeByte(10)
      ..write(obj.isOpen24Hours)
      ..writeByte(11)
      ..write(obj.operatingHours)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TruckLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationReviewAdapter extends TypeAdapter<LocationReview> {
  @override
  final int typeId = 11;

  @override
  LocationReview read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationReview(
      id: fields[0] as String,
      locationId: fields[1] as String,
      userId: fields[2] as String,
      userName: fields[3] as String,
      rating: fields[4] as int,
      comment: fields[5] as String,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocationReview obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.locationId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.comment)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationReviewAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ParkingStatusUpdateAdapter extends TypeAdapter<ParkingStatusUpdate> {
  @override
  final int typeId = 12;

  @override
  ParkingStatusUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ParkingStatusUpdate(
      id: fields[0] as String,
      locationId: fields[1] as String,
      userId: fields[2] as String,
      userName: fields[3] as String,
      status: fields[4] as ParkingStatus,
      timestamp: fields[5] as DateTime,
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ParkingStatusUpdate obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.locationId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.userName)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParkingStatusUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FavoriteLocationAdapter extends TypeAdapter<FavoriteLocation> {
  @override
  final int typeId = 13;

  @override
  FavoriteLocation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteLocation(
      id: fields[0] as String,
      locationId: fields[1] as String,
      userId: fields[2] as String,
      addedAt: fields[3] as DateTime,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteLocation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.locationId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.addedAt)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteLocationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationStatsAdapter extends TypeAdapter<LocationStats> {
  @override
  final int typeId = 14;

  @override
  LocationStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocationStats(
      locationId: fields[0] as String,
      averageRating: fields[1] as double,
      totalReviews: fields[2] as int,
      currentParkingStatus: fields[3] as ParkingStatus?,
      lastParkingUpdate: fields[4] as DateTime?,
      favoriteCount: fields[5] as int,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocationStats obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.locationId)
      ..writeByte(1)
      ..write(obj.averageRating)
      ..writeByte(2)
      ..write(obj.totalReviews)
      ..writeByte(3)
      ..write(obj.currentParkingStatus)
      ..writeByte(4)
      ..write(obj.lastParkingUpdate)
      ..writeByte(5)
      ..write(obj.favoriteCount)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

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
