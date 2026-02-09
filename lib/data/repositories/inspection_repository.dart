import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../../core/services/firebase_service.dart';
import '../models/inspection_models.dart';
import '../../core/constants/localized_inspection_data.dart';

/// Repository for managing inspection data using Firestore
class InspectionRepository {
  final FirebaseService _firebase = FirebaseService.instance;
  final Uuid _uuid = const Uuid();
  
  CollectionReference<Map<String, dynamic>> get _inspectionsCollection => 
      _firebase.collection('inspections');

  /// Get all inspections
  /// Note: Returns empty list synchronously. Use fetchAllInspections for async.
  List<Inspection> getAllInspections() {
     return [];
  }
  
  /// Fetch all inspections from Firestore
  Future<List<Inspection>> fetchAllInspections() async {
    try {
      final snapshot = await _inspectionsCollection
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching inspections: $e');
      return [];
    }
  }

  /// Get inspection by ID
  Future<Inspection?> getInspectionById(String id) async {
    try {
      final doc = await _inspectionsCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return Inspection.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get inspections by status
  Future<List<Inspection>> getInspectionsByStatus(InspectionStatus status) async {
    try {
      // Map enum to string if needed, or rely on toJson serialization
      // InspectionStatus is usually serialized to string in json
      // We need to know how it's serialized. Assuming string based on models.
      // We'll filter client side if unsure or query if we know the string value.
      // Let's assume client side filter for safety first or fetchAll.
      // Actually, let's query.
      final snapshot = await _inspectionsCollection
          .where('status', isEqualTo: status.toString().split('.').last) 
          .orderBy('created_at', descending: true)
          .get();
          
      // Fallback: if enum serialization is complex, we might need to check how it's stored.
      // Usually Hive adapters store indices or strings. Json serialization usually strings.
      // Let's assume standard JSON serialization.
      
      return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
    } catch (e) {
       // Fallback to client side filter
       final all = await fetchAllInspections();
       return all.where((i) => i.status == status).toList();
    }
  }

  /// Get inspections by date range
  Future<List<Inspection>> getInspectionsByDateRange(DateTime start, DateTime end) async {
    try {
       final snapshot = await _inspectionsCollection
          .where('created_at', isGreaterThanOrEqualTo: start.toIso8601String())
          .where('created_at', isLessThanOrEqualTo: end.toIso8601String())
          .orderBy('created_at', descending: true)
          .get();
      return snapshot.docs.map((doc) => Inspection.fromJson(doc.data())).toList();
    } catch (e) {
      // Fallback
       final all = await fetchAllInspections();
       return all.where((i) => i.createdAt.isAfter(start) && i.createdAt.isBefore(end)).toList();
    }
  }

  /// Get recent inspections (last 30 days)
  Future<List<Inspection>> getRecentInspections() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return getInspectionsByDateRange(thirtyDaysAgo, DateTime.now());
  }

  /// Create new inspection
  Future<Inspection> createInspection({
    required BuildContext context,
    required String driverId,
    required String driverName,
    required Vehicle vehicle,
    required InspectionType type,
    LocationInfo? location,
  }) async {
    final inspection = Inspection(
      id: _uuid.v4(),
      driverId: driverId,
      driverName: driverName,
      vehicle: vehicle,
      type: type,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(), // Ensure updated at is set
      location: location,
      items: LocalizedInspectionData.getAllInspectionItems(context),
      status: InspectionStatus.inProgress, // Default status
    );

    await _inspectionsCollection.doc(inspection.id).set(inspection.toJson());
    return inspection;
  }

  /// Update inspection
  Future<void> updateInspection(Inspection inspection) async {
    final updated = inspection.copyWith(updatedAt: DateTime.now());
    await _inspectionsCollection.doc(inspection.id).update(updated.toJson());
  }

  /// Update inspection item
  Future<void> updateInspectionItem(
    String inspectionId, 
    InspectionItem updatedItem,
  ) async {
    final inspection = await getInspectionById(inspectionId);
    if (inspection == null) return;

    final itemIndex = inspection.items.indexWhere((item) => item.id == updatedItem.id);
    if (itemIndex == -1) return;

    // Create a new list to avoid modifying the original (immutability)
    final newItems = List<InspectionItem>.from(inspection.items);
    newItems[itemIndex] = updatedItem;
    
    final updatedInspection = inspection.copyWith(items: newItems);
    await updateInspection(updatedInspection);
  }

  /// Complete inspection
  Future<void> completeInspection(
    String inspectionId, 
    String signature,
    {String? overallNotes}
  ) async {
    final inspection = await getInspectionById(inspectionId);
    if (inspection == null) return;

    final completedInspection = inspection.copyWith(
      status: InspectionStatus.completed,
      completedAt: DateTime.now(),
      signature: signature,
      overallNotes: overallNotes,
    );

    await updateInspection(completedInspection);
  }

  /// Delete inspection
  Future<void> deleteInspection(String id) async {
    await _inspectionsCollection.doc(id).delete();
  }

  /// Get unsynced inspections (Not applicable for Firestore as it syncs automatically)
  List<Inspection> getUnsyncedInspections() {
    return [];
  }

  /// Mark inspection as synced (Not applicable)
  Future<void> markInspectionAsSynced(String id) async {
    // No-op
  }

  /// Get inspection statistics
  Future<Map<String, dynamic>> getInspectionStats() async {
    final inspections = await fetchAllInspections();
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final recentInspections = inspections
        .where((i) => i.createdAt.isAfter(thirtyDaysAgo))
        .toList();

    return {
      'total': inspections.length,
      'recent': recentInspections.length,
      'completed': inspections
          .where((i) => i.status == InspectionStatus.completed)
          .length,
      'failed': inspections
          .where((i) => i.status == InspectionStatus.failed)
          .length,
      'pending': inspections
          .where((i) => i.status == InspectionStatus.pending)
          .length,
      'inProgress': inspections
          .where((i) => i.status == InspectionStatus.inProgress)
          .length,
      'unsynced': 0, // Firestore handles sync
      'withCriticalDefects': inspections
          .where((i) => i.hasCriticalDefects)
          .length,
    };
  }
}