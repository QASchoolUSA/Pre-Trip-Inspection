import 'dart:async';

import '../models/load_models.dart';
import '../../core/services/supabase_service.dart';

class LoadRepository {
  LoadRepository();

  Future<List<Load>> getLoadsForDriver(String driverId) async {
    final supabase = SupabaseService.instance;
    if (supabase.isInitialized && supabase.client != null) {
      try {
        final rows = await supabase.fetchLoadsForDriver(driverId);
        return rows.map(_mapRowToLoad).toList();
      } catch (_) {
        // If Supabase errors (e.g., 404 table missing), fall back to sample data
      }
    }

    // Fallback sample data when Supabase is not configured
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

  Load _mapRowToLoad(Map<String, dynamic> row) {
    final statusStr = (row['status'] as String?) ?? 'assigned';
    final status = _statusFromString(statusStr);
    return Load(
      id: row['id'].toString(),
      driverId: row['driver_id'].toString(),
      referenceNumber: row['reference_number'] ?? '',
      pickupCity: row['pickup_city'] ?? '',
      pickupState: row['pickup_state'] ?? '',
      pickupTime: DateTime.parse((row['pickup_time'] ?? row['pickup_date']).toString()),
      dropoffCity: row['dropoff_city'] ?? '',
      dropoffState: row['dropoff_state'] ?? '',
      dropoffTime: DateTime.parse((row['dropoff_time'] ?? row['dropoff_date']).toString()),
      status: status,
      weightLbs: (row['weight_lbs'] as num?)?.toDouble(),
      rateUsd: (row['rate_usd'] as num?)?.toDouble(),
      brokerName: row['broker_name'] as String?,
      notes: row['notes'] as String?,
    );
  }

  LoadStatus _statusFromString(String s) {
    switch (s) {
      case 'assigned':
        return LoadStatus.assigned;
      case 'inTransit':
      case 'in_transit':
        return LoadStatus.inTransit;
      case 'delivered':
        return LoadStatus.delivered;
      case 'cancelled':
        return LoadStatus.cancelled;
      default:
        return LoadStatus.assigned;
    }
  }
}