import '../models/inspection_models.dart';
import '../datasources/database_service.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing user data
class UserRepository {
  final DatabaseService _db = DatabaseService.instance;
  final Uuid _uuid = const Uuid();

  /// Get all users
  List<User> getAllUsers() {
    return _db.usersBox.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get active users
  List<User> getActiveUsers() {
    return _db.usersBox.values
        .where((user) => user.isActive)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get user by ID
  User? getUserById(String id) {
    return _db.usersBox.get(id);
  }

  /// Get user by CDL number
  User? getUserByCdlNumber(String cdlNumber) {
    return _db.usersBox.values
        .where((user) => user.cdlNumber == cdlNumber)
        .firstOrNull;
  }

  /// Create new user
  Future<User> createUser({
    required String name,
    required String cdlNumber,
    DateTime? cdlExpiryDate,
    DateTime? medicalCertExpiryDate,
    String? phoneNumber,
    String? email,
  }) async {
    final user = User(
      id: _uuid.v4(),
      name: name,
      cdlNumber: cdlNumber,
      cdlExpiryDate: cdlExpiryDate,
      medicalCertExpiryDate: medicalCertExpiryDate,
      phoneNumber: phoneNumber,
      email: email,
    );

    await _db.usersBox.put(user.id, user);
    return user;
  }

  /// Update user
  Future<void> updateUser(User user) async {
    await _db.usersBox.put(user.id, user);
  }

  /// Update user login timestamp
  Future<void> updateLastLogin(String id) async {
    final user = getUserById(id);
    if (user == null) return;

    final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
    await updateUser(updatedUser);
  }

  /// Deactivate user
  Future<void> deactivateUser(String id) async {
    final user = getUserById(id);
    if (user == null) return;

    final deactivatedUser = user.copyWith(isActive: false);
    await updateUser(deactivatedUser);
  }

  /// Activate user
  Future<void> activateUser(String id) async {
    final user = getUserById(id);
    if (user == null) return;

    final activatedUser = user.copyWith(isActive: true);
    await updateUser(activatedUser);
  }

  /// Delete user
  Future<void> deleteUser(String id) async {
    await _db.usersBox.delete(id);
  }

  /// Search users by name or CDL number
  List<User> searchUsers(String query) {
    final lowercaseQuery = query.toLowerCase();
    
    return _db.usersBox.values
        .where((user) =>
            user.name.toLowerCase().contains(lowercaseQuery) ||
            user.cdlNumber.toLowerCase().contains(lowercaseQuery) ||
            (user.email?.toLowerCase().contains(lowercaseQuery) ?? false))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get users with expiring CDL (within next 30 days)
  List<User> getUsersWithExpiringCdl() {
    return _db.usersBox.values
        .where((user) => user.isActive && user.isCdlExpiringSoon)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get users with expiring medical certificate (within next 30 days)
  List<User> getUsersWithExpiringMedicalCert() {
    return _db.usersBox.values
        .where((user) => user.isActive && user.isMedicalCertExpiringSoon)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get users with any expiring documents
  List<User> getUsersWithExpiringDocuments() {
    return _db.usersBox.values
        .where((user) => 
            user.isActive && 
            (user.isCdlExpiringSoon || user.isMedicalCertExpiringSoon))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Get user statistics
  Map<String, dynamic> getUserStats() {
    final users = getAllUsers();
    final activeUsers = getActiveUsers();
    
    return {
      'total': users.length,
      'active': activeUsers.length,
      'inactive': users.length - activeUsers.length,
      'expiringCdl': getUsersWithExpiringCdl().length,
      'expiringMedicalCert': getUsersWithExpiringMedicalCert().length,
      'expiringDocuments': getUsersWithExpiringDocuments().length,
      'recentLogins': _getRecentLoginCount(),
    };
  }

  /// Get count of users who logged in within last 7 days
  int _getRecentLoginCount() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    
    return _db.usersBox.values
        .where((user) => 
            user.lastLoginAt != null && 
            user.lastLoginAt!.isAfter(sevenDaysAgo))
        .length;
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
        email: 'john.smith@trucking.com',
      ),
      User(
        id: _uuid.v4(),
        name: 'Maria Garcia',
        cdlNumber: 'CDL789012',
        cdlExpiryDate: DateTime.now().add(const Duration(days: 365)),
        medicalCertExpiryDate: DateTime.now().add(const Duration(days: 120)),
        phoneNumber: '555-0102',
        email: 'maria.garcia@trucking.com',
      ),
      User(
        id: _uuid.v4(),
        name: 'Robert Johnson',
        cdlNumber: 'CDL345678',
        cdlExpiryDate: DateTime.now().add(const Duration(days: 20)), // Expiring soon
        medicalCertExpiryDate: DateTime.now().add(const Duration(days: 15)), // Expiring soon
        phoneNumber: '555-0103',
        email: 'robert.johnson@trucking.com',
      ),
    ];

    for (final user in sampleUsers) {
      await _db.usersBox.put(user.id, user);
    }
  }
}