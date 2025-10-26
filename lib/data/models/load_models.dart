import 'package:flutter/foundation.dart';

enum LoadStatus { assigned, inTransit, delivered, cancelled }

class Load {
  final String id;
  final String driverId;
  final String referenceNumber;
  final String pickupCity;
  final String pickupState;
  final DateTime pickupTime;
  final String dropoffCity;
  final String dropoffState;
  final DateTime dropoffTime;
  final LoadStatus status;
  final double? weightLbs;
  final double? rateUsd;
  final String? brokerName;
  final String? notes;

  const Load({
    required this.id,
    required this.driverId,
    required this.referenceNumber,
    required this.pickupCity,
    required this.pickupState,
    required this.pickupTime,
    required this.dropoffCity,
    required this.dropoffState,
    required this.dropoffTime,
    required this.status,
    this.weightLbs,
    this.rateUsd,
    this.brokerName,
    this.notes,
  });

  Load copyWith({
    String? id,
    String? driverId,
    String? referenceNumber,
    String? pickupCity,
    String? pickupState,
    DateTime? pickupTime,
    String? dropoffCity,
    String? dropoffState,
    DateTime? dropoffTime,
    LoadStatus? status,
    double? weightLbs,
    double? rateUsd,
    String? brokerName,
    String? notes,
  }) {
    return Load(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      pickupCity: pickupCity ?? this.pickupCity,
      pickupState: pickupState ?? this.pickupState,
      pickupTime: pickupTime ?? this.pickupTime,
      dropoffCity: dropoffCity ?? this.dropoffCity,
      dropoffState: dropoffState ?? this.dropoffState,
      dropoffTime: dropoffTime ?? this.dropoffTime,
      status: status ?? this.status,
      weightLbs: weightLbs ?? this.weightLbs,
      rateUsd: rateUsd ?? this.rateUsd,
      brokerName: brokerName ?? this.brokerName,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Load($referenceNumber: $pickupCity, $pickupState -> $dropoffCity, $dropoffState)';
  }
}