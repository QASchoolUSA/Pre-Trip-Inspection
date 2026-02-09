import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
// import '../../data/models/inspection_models.dart';
import 'firebase_service.dart';

/// Service for handling authentication with Firebase Auth
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  final FirebaseService _firebase = FirebaseService.instance;
  
  firebase_auth.FirebaseAuth get _auth => _firebase.auth;
  FirebaseFirestore get _firestore => _firebase.firestore;

  /// Initialize the auth service
  Future<void> initialize() async {
    // Firebase is initialized in FirebaseService
    if (!_firebase.isInitialized) {
      await _firebase.initialize();
    }
    
    // Listen to auth state changes
    _auth.authStateChanges().listen((firebase_auth.User? user) {
      if (kDebugMode) {
        print('Auth state changed: ${user?.uid}');
      }
    });
  }

  /// Login with email and password
  /// NOTE: This does NOT fetch from Firestore to avoid cold start delays
  /// Profile data will be fetched lazily on dashboard if needed
  Future<AuthResult> login(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Return Firebase Auth user data immediately - no Firestore call!
        // This eliminates 5-15 second Firestore cold start delay on web
        return AuthResult.success({
          'id': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? user.email?.split('@').first ?? 'User',
          'cdlNumber': '', // Will be populated on profile fetch later
          'isActive': true,
        });
      } else {
        return AuthResult.failure('Login failed: No user returned');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_handleAuthError(e));
    } catch (e) {
      return AuthResult.failure('Unexpected error: $e');
    }
  }
  
  /// Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
    required String cdlNumber,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // Create user document in Firestore
        final userData = {
          'id': user.uid,
          'name': name,
          'email': email,
          'role': role,
          'cdl_number': cdlNumber,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        await _firestore.collection('users').doc(user.uid).set(userData);
        
        return AuthResult.success(userData);
      } else {
        return AuthResult.failure('Sign up failed: No user returned');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      return AuthResult.failure(_handleAuthError(e));
    } catch (e) {
      return AuthResult.failure('Unexpected error: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// Get current user data
  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _fetchUserData(user.uid);
    }
    return null;
  }

  /// Get basic user data from Firebase Auth (instant, no Firestore fetch)
  Map<String, dynamic>? getCurrentUserBasicData() {
    final user = _auth.currentUser;
    if (user != null) {
      return {
        'id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? user.email?.split('@').first ?? 'User',
        'cdlNumber': '', // Will be populated on profile fetch later
        'isActive': true,
      };
    }
    return null;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  /// Fetch user data from Firestore
  Future<Map<String, dynamic>?> _fetchUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data: $e');
      }
      return null;
    }
  }
  
  /// Handle Firebase Auth errors
  String _handleAuthError(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

/// Result class for authentication operations
class AuthResult {
  final bool success;
  final Map<String, dynamic>? userData;
  final String? error;

  const AuthResult._({
    required this.success,
    this.userData,
    this.error,
  });

  factory AuthResult.success(Map<String, dynamic> userData) {
    return AuthResult._(success: true, userData: userData);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(success: false, error: error);
  }
}