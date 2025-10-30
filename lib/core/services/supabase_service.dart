import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  SupabaseService._();

  SupabaseClient? _client;
  bool _initialized = false;

  SupabaseClient? get client => _client;
  bool get isInitialized => _initialized && _client != null;

  Future<void> initialize() async {
    if (_initialized) return;
    if (!SupabaseConfig.isConfigured) {
      _initialized = true;
      return;
    }

    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
    _initialized = true;
  }

  Future<List<Map<String, dynamic>>> fetchLoadsForDriver(String driverId) async {
    if (!isInitialized) return [];
    // Apply server-side filter only if driverId is an integer to avoid type mismatch
    final driverInt = int.tryParse(driverId);
    final response = driverInt != null
        ? await _client!
            .from('loads')
            .select()
            .eq('driver_id', driverInt)
            .order('pickup_date', ascending: true)
        : await _client!
            .from('loads')
            .select()
            .order('pickup_date', ascending: true);
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<bool> upsertInspection(Map<String, dynamic> data) async {
    if (!isInitialized) return false;
    try {
      // Sanitize potential type mismatches for integer columns
      // If driver_id or vehicle_id are non-integer strings, omit them to avoid 22P02 errors
      final sanitized = Map<String, dynamic>.from(data);

      // If the primary key 'id' is expected to be integer in DB, and we have a UUID/string,
      // remove it so the server can auto-generate. This prevents 22P02 on integer columns.
      final idVal = sanitized['id'];
      if (idVal is String && int.tryParse(idVal) == null) {
        sanitized.remove('id');
      }

      final driverId = sanitized['driver_id'];
      if (driverId is String && int.tryParse(driverId) == null) {
        sanitized.remove('driver_id');
      }
      final vehicleId = sanitized['vehicle_id'];
      if (vehicleId is String && int.tryParse(vehicleId) == null) {
        sanitized.remove('vehicle_id');
      }

      await _client!.from('inspections').upsert(sanitized, onConflict: 'id');
      return true;
    } catch (e) {
      print('Error upserting inspection: $e');
      return false;
    }
  }

  Future<void> upsertUser(Map<String, dynamic> data) async {
    if (!isInitialized) return;
    // If a user exists with the same email but different id, reuse existing id to avoid unique email conflicts
    try {
      final email = data['email'] as String?;
      if (email != null && email.isNotEmpty) {
        final rows = await _client!
            .from('users')
            .select('id')
            .eq('email', email)
            .limit(1);
        final list = (rows as List).cast<Map<String, dynamic>>();
        if (list.isNotEmpty) {
          final existingId = list.first['id'].toString();
          data['id'] = existingId; // ensure merge occurs on existing row
        }
      }
    } catch (_) {}

    await _client!.from('users').upsert(data, onConflict: 'id');
  }

  /// Get a user by email, returns first match or null
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (!isInitialized) return null;
    final rows = await _client!
        .from('users')
        .select()
        .eq('email', email)
        .limit(1);
    final list = (rows as List).cast<Map<String, dynamic>>();
    return list.isNotEmpty ? list.first : null;
  }

  /// Upload a photo to Supabase Storage
  /// Returns the public URL of the uploaded file
  Future<String?> uploadPhoto(String bucketName, String filePath, Uint8List fileBytes) async {
    if (!isInitialized) return null;
    
    try {
      final response = await _client!.storage
          .from(bucketName)
          .uploadBinary(filePath, fileBytes);
      
      // Get the public URL for the uploaded file
      final publicUrl = _client!.storage
          .from(bucketName)
          .getPublicUrl(filePath);
      
      return publicUrl;
    } catch (e) {
      print('Error uploading photo: $e');
      return null;
    }
  }

  /// Delete a photo from Supabase Storage
  Future<bool> deletePhoto(String bucketName, String filePath) async {
    if (!isInitialized) return false;
    
    try {
      await _client!.storage
          .from(bucketName)
          .remove([filePath]);
      return true;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }
}