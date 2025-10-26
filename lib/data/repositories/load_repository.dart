import 'dart:async';

import '../models/load_models.dart';

class LoadRepository {
  LoadRepository();

  // In a real app, replace with API/database call.
  Future<List<Load>> getLoadsForDriver(String driverId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final now = DateTime.now();
    final sample = <Load>[
      Load(
        id: 'L-001',
        driverId: driverId,
        referenceNumber: 'REF-78421',
        pickupCity: 'Dallas',
        pickupState: 'TX',
        pickupTime: now.add(const Duration(hours: 4)),
        dropoffCity: 'Atlanta',
        dropoffState: 'GA',
        dropoffTime: now.add(const Duration(days: 1, hours: 6)),
        status: LoadStatus.assigned,
        weightLbs: 38000,
        rateUsd: 2100,
        brokerName: 'Acme Logistics',
      ),
      Load(
        id: 'L-002',
        driverId: driverId,
        referenceNumber: 'REF-78422',
        pickupCity: 'Memphis',
        pickupState: 'TN',
        pickupTime: now.subtract(const Duration(days: 1, hours: 2)),
        dropoffCity: 'Chicago',
        dropoffState: 'IL',
        dropoffTime: now.add(const Duration(hours: 10)),
        status: LoadStatus.inTransit,
        weightLbs: 42000,
        rateUsd: 1850,
        brokerName: 'North Freight',
      ),
      Load(
        id: 'L-003',
        driverId: driverId,
        referenceNumber: 'REF-78423',
        pickupCity: 'Phoenix',
        pickupState: 'AZ',
        pickupTime: now.subtract(const Duration(days: 3)),
        dropoffCity: 'Los Angeles',
        dropoffState: 'CA',
        dropoffTime: now.subtract(const Duration(days: 2, hours: 8)),
        status: LoadStatus.delivered,
        weightLbs: 40000,
        rateUsd: 1600,
        brokerName: 'Sunrise Carriers',
      ),
    ];

    return sample;
  }
}