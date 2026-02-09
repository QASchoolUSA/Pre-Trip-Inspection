import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/services/firebase_service.dart';
import '../models/load_models.dart';

class LoadRepository {
  final FirebaseService _firebase = FirebaseService.instance;
  
  CollectionReference<Map<String, dynamic>> get _loadsCollection => 
      _firebase.collection('loads');

  LoadRepository();

  /// Get loads for a specific driver
  Future<List<Load>> getLoadsForDriver(String driverId) async {
    try {
      final snapshot = await _loadsCollection
          .where('driverId', isEqualTo: driverId)
          .orderBy('pickupTime', descending: false)
          .get();
      
      return snapshot.docs.map((doc) => Load.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching loads: $e');
      return [];
    }
  }

  /// Create a new load
  Future<void> createLoad(Load load) async {
    await _loadsCollection.doc(load.id).set(load.toJson());
  }

  /// Update load status
  Future<void> updateLoadStatus(String loadId, LoadStatus status) async {
    await _loadsCollection.doc(loadId).update({
      'status': status.toString().split('.').last, // Assuming enum serialization
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}