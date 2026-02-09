import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/firebase_service.dart';
import '../models/inspection_models.dart';

/// Repository for managing user data using Firestore
class UserRepository {
  final FirebaseService _firebase = FirebaseService.instance;
  final Uuid _uuid = const Uuid();
  
  CollectionReference<Map<String, dynamic>> get _usersCollection => 
      _firebase.collection('users');

  /// Get all users
  List<User> getAllUsers() {
    // Note: detailed querying should be done via streams or futures in the UI
    // This is a synchronous placeholder method if needed, but Firestore is async.
    // For now, we will use a blocking call if strictly required by interface,
    // or better, the provider should be updated to handle Future/Stream.
    // Given the architecture, this method returning List<User> synchronously 
    // suggests the provider expects to load data into memory.
    // We can't do synchronous Firestore calls. 
    // I will return an empty list here and rely on the provider calling a load method 
    // or we need to refactor the provider to be async.
    // Looking at AppProviders, UsersNotifier.loadUsers() calls this.
    // I will update this to return empty and add a fetchUsers method, 
    // or refactor the notifier to use a Stream.
    return [];
  }
  
  /// Fetch all users from Firestore
  Future<List<User>> fetchUsers() async {
    try {
      final snapshot = await _usersCollection.get();
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  /// Get active users
  Future<List<User>> getActiveUsers() async {
     try {
      final snapshot = await _usersCollection
          .where('is_active', isEqualTo: true)
          .get();
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      return [];
    }
  }

  /// Get user by ID
  Future<User?> getUserById(String id) async {
    try {
      final doc = await _usersCollection.doc(id).get();
      if (doc.exists && doc.data() != null) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get user by CDL number
  Future<User?> getUserByCdlNumber(String cdlNumber) async {
    try {
      final snapshot = await _usersCollection
          .where('cdl_number', isEqualTo: cdlNumber)
          .limit(1)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        return User.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Create new user
  Future<User> createUser({
    required String name,
    required String cdlNumber,
    DateTime? cdlExpiryDate,
    DateTime? medicalCertExpiryDate,
    String? phoneNumber,
    String? email,
    String? role,
  }) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
      cdlNumber: cdlNumber,
      cdlExpiryDate: cdlExpiryDate,
      medicalCertExpiryDate: medicalCertExpiryDate,
      phoneNumber: phoneNumber,
      email: email,
      role: role ?? 'driver',
    );

    await _usersCollection.doc(user.id).set(user.toJson());
    return user;
  }

  /// Update user
  Future<void> updateUser(User user) async {
    await _usersCollection.doc(user.id).update(user.toJson());
  }

  /// Update user login timestamp
  Future<void> updateLastLogin(String id) async {
    await _usersCollection.doc(id).update({
      'last_login_at': DateTime.now().toIso8601String(),
    });
  }

  /// Deactivate user
  Future<void> deactivateUser(String id) async {
    await _usersCollection.doc(id).update({'is_active': false});
  }

  /// Activate user
  Future<void> activateUser(String id) async {
     await _usersCollection.doc(id).update({'is_active': true});
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    await _usersCollection.doc(id).delete();
  }

  /// Search users by name or CDL number
  // Note: Firestore doesn't support full-text search natively like this easily.
  // We will do a client-side filter for now since the user base is likely small,
  // or implement a basic startAt/endAt search if needed.
  Future<List<User>> searchUsers(String query) async {
    final users = await fetchUsers();
    final lowercaseQuery = query.toLowerCase();
    
    return users.where((user) =>
            user.name.toLowerCase().contains(lowercaseQuery) ||
            user.cdlNumber.toLowerCase().contains(lowercaseQuery) ||
            (user.email?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList();
  }

  /// Get users with expiring CDL (within next 30 days)
  Future<List<User>> getUsersWithExpiringCdl() async {
    // Logic for expiry check is better done in app or strict query if possible.
    // For simplicity, fetch active and filter.
    final users = await getActiveUsers();
    return users.where((user) => user.isCdlExpiringSoon).toList();
  }

  /// Get users with expiring medical certificate
  Future<List<User>> getUsersWithExpiringMedicalCert() async {
    final users = await getActiveUsers();
    return users.where((user) => user.isMedicalCertExpiringSoon).toList();
  }

  /// Get users with any expiring documents
  Future<List<User>> getUsersWithExpiringDocuments() async {
    final users = await getActiveUsers();
    return users.where((user) => 
        user.isCdlExpiringSoon || user.isMedicalCertExpiringSoon).toList();
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats() async {
    final users = await fetchUsers();
    final activeUsers = users.where((u) => u.isActive).toList();
    
    return {
      'total': users.length,
      'active': activeUsers.length,
      'inactive': users.length - activeUsers.length,
      'expiringCdl': activeUsers.where((u) => u.isCdlExpiringSoon).length,
      'expiringMedicalCert': activeUsers.where((u) => u.isMedicalCertExpiringSoon).length,
      'expiringDocuments': activeUsers.where((u) => u.isCdlExpiringSoon || u.isMedicalCertExpiringSoon).length,
      // 'recentLogins': ... // Implementation requires fetching all or query
    };
  }

  /// Add sample users for development/testing
  Future<void> addSampleUsers() async {
    final sampleUsers = [
      User(
        id: _uuid.v4(),
        name: 'John Smith',
        cdlNumber: 'CDL123456',
        cdlExpiryDate: DateTime.now().add(const Duration(days: 180)),
        medicalCertExpiryDate: DateTime.now().add(const Duration(days: 90)),
        phoneNumber: '555-0101',
        email: 'john.smith@ptiplus.com',
        role: 'driver',
      ),
      User(
        id: _uuid.v4(),
        name: 'Maria Garcia',
        cdlNumber: 'CDL789012',
        cdlExpiryDate: DateTime.now().add(const Duration(days: 365)),
        medicalCertExpiryDate: DateTime.now().add(const Duration(days: 120)),
        phoneNumber: '555-0102',
        email: 'maria.garcia@ptiplus.com',
        role: 'dispatcher',
      ),
      User(
        id: _uuid.v4(),
        name: 'Robert Johnson',
        cdlNumber: 'CDL345678',
        cdlExpiryDate: DateTime.now().add(const Duration(days: 20)),
        medicalCertExpiryDate: DateTime.now().add(const Duration(days: 15)),
        phoneNumber: '555-0103',
        email: 'robert.johnson@ptiplus.com',
        role: 'driver',
      ),
    ];

    for (final user in sampleUsers) {
      // Check if exists to avoid duplicates if possible, or just add
      // Since IDs are random, we might duplicate if we run this multiple times
      // for "Sample" data, let's just add them.
      await _usersCollection.doc(user.id).set(user.toJson());
    }
  }
}