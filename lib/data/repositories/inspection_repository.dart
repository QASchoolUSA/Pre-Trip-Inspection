import '../models/inspection_models.dart';
import '../datasources/database_service.dart';
import '../../core/constants/inspection_data.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing inspection data
class InspectionRepository {
  final DatabaseService _db = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  /// Get all inspections
  List<Inspection> getAllInspections() {
    return _db.inspectionsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get inspection by ID
  Inspection? getInspectionById(String id) {
    return _db.inspectionsBox.get(id);
  }

  /// Get inspections by status
  List<Inspection> getInspectionsByStatus(InspectionStatus status) {
    return _db.inspectionsBox.values
        .where((inspection) => inspection.status == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get inspections by date range
  List<Inspection> getInspectionsByDateRange(DateTime start, DateTime end) {
    return _db.inspectionsBox.values
        .where((inspection) => 
            inspection.createdAt.isAfter(start) && 
            inspection.createdAt.isBefore(end))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get recent inspections (last 30 days)
  List<Inspection> getRecentInspections() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return getInspectionsByDateRange(thirtyDaysAgo, DateTime.now());
  }

  /// Create new inspection
  Future<Inspection> createInspection({
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
      location: location,
      items: InspectionData.getAllInspectionItems(),
    );

    await _db.inspectionsBox.put(inspection.id, inspection);
    return inspection;
  }

  /// Update inspection
  Future<void> updateInspection(Inspection inspection) async {
    await _db.inspectionsBox.put(inspection.id, inspection);
  }

  /// Update inspection item
  Future<void> updateInspectionItem(
    String inspectionId, 
    InspectionItem updatedItem,
  ) async {
    final inspection = getInspectionById(inspectionId);
    if (inspection == null) return;

    final itemIndex = inspection.items.indexWhere((item) => item.id == updatedItem.id);
    if (itemIndex == -1) return;

    inspection.items[itemIndex] = updatedItem;
    await updateInspection(inspection);
  }

  /// Complete inspection
  Future<void> completeInspection(
    String inspectionId, 
    String signature,
    {String? overallNotes}
  ) async {
    final inspection = getInspectionById(inspectionId);
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
    await _db.inspectionsBox.delete(id);
  }

  /// Get unsynced inspections
  List<Inspection> getUnsyncedInspections() {
    return _db.inspectionsBox.values
        .where((inspection) => !inspection.isSynced)
        .toList();
  }

  /// Mark inspection as synced
  Future<void> markInspectionAsSynced(String id) async {
    final inspection = getInspectionById(id);
    if (inspection == null) return;

    final syncedInspection = inspection.copyWith(
      isSynced: true,
      lastSyncAt: DateTime.now(),
    );

    await updateInspection(syncedInspection);
  }

  /// Get inspection statistics
  Map<String, dynamic> getInspectionStats() {
    final inspections = getAllInspections();
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
      'unsynced': getUnsyncedInspections().length,
      'withCriticalDefects': inspections
          .where((i) => i.hasCriticalDefects)
          .length,
    };
  }
}