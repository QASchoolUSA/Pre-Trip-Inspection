import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';

/// Service for handling authentication with PostgreSQL backend
class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _tokenExpiryKey = 'token_expiry';

  SharedPreferences? _prefs;
  late final Dio _dio;

  /// Initialize the auth service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      headers: ApiConfig.defaultHeaders,
    ));
  }

  /// Login with username and password
  Future<AuthResult> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        final accessToken = data['access_token'] as String;
        final refreshToken = data['refresh_token'] as String;
        final userData = data['user'] as Map<String, dynamic>;
        final expiresIn = data['expires_in'] as int; // seconds

        // Calculate expiry time
        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));

        // Store tokens and user data
        await _storeTokens(accessToken, refreshToken, expiryTime);
        await _storeUserData(userData);

        return AuthResult.success(userData);
      } else {
        throw ApiException('Login failed', ApiErrorType.unauthorized);
      }
    } on DioException catch (e) {
      // Add specific handling for intermittent network issues
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw ApiException(
          'Connection timeout. Please check your internet connection and try again.',
          ApiErrorType.network,
        );
      }
      throw _handleAuthError(e);
    } catch (e) {
      throw ApiException(
        'Unexpected error during login: ${e.toString()}',
        ApiErrorType.unknown,
      );
    }
  }

  /// Refresh access token using refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        throw ApiException('No refresh token available', ApiErrorType.unauthorized);
      }

      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        
        final newAccessToken = data['access_token'] as String;
        final newRefreshToken = data['refresh_token'] as String?;
        final expiresIn = data['expires_in'] as int;

        final expiryTime = DateTime.now().add(Duration(seconds: expiresIn));

        // Store new tokens
        await _storeTokens(
          newAccessToken, 
          newRefreshToken ?? refreshToken, 
          expiryTime,
        );

        return true;
      } else {
        await logout();
        return false;
      }
    } on DioException catch (e) {
      await logout();
      throw _handleAuthError(e);
    }
  }

  /// Logout user and clear stored data
  Future<void> logout() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken != null) {
        // Notify server about logout
        await _dio.post(
          ApiConfig.logoutEndpoint,
          options: Options(
            headers: ApiConfig.getAuthHeaders(accessToken),
          ),
        );
      }
    } catch (e) {
      // Ignore logout errors, still clear local data
    } finally {
      await _clearStoredData();
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    await _ensureInitialized();
    return _prefs!.getString(_accessTokenKey);
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    return _prefs!.getString(_refreshTokenKey);
  }

  /// Get stored user data
  Future<Map<String, dynamic>?> getUserData() async {
    await _ensureInitialized();
    final userDataString = _prefs!.getString(_userDataKey);
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    // Check if token is expired
    if (await _isTokenExpired()) {
      // Try to refresh token
      try {
        return await refreshToken();
      } catch (e) {
        return false;
      }
    }

    return true;
  }

  /// Check if access token is expired
  Future<bool> _isTokenExpired() async {
    await _ensureInitialized();
    final expiryString = _prefs!.getString(_tokenExpiryKey);
    if (expiryString == null) return true;

    final expiryTime = DateTime.parse(expiryString);
    final now = DateTime.now();
    
    // Consider token expired if it expires within 5 minutes
    return now.isAfter(expiryTime.subtract(const Duration(minutes: 5)));
  }

  /// Store tokens securely
  Future<void> _storeTokens(String accessToken, String refreshToken, DateTime expiryTime) async {
    await _ensureInitialized();
    await Future.wait([
      _prefs!.setString(_accessTokenKey, accessToken),
      _prefs!.setString(_refreshTokenKey, refreshToken),
      _prefs!.setString(_tokenExpiryKey, expiryTime.toIso8601String()),
    ]);
  }

  /// Store user data
  Future<void> _storeUserData(Map<String, dynamic> userData) async {
    await _ensureInitialized();
    await _prefs!.setString(_userDataKey, jsonEncode(userData));
  }

  /// Clear all stored authentication data
  Future<void> _clearStoredData() async {
    await _ensureInitialized();
    await Future.wait([
      _prefs!.remove(_accessTokenKey),
      _prefs!.remove(_refreshTokenKey),
      _prefs!.remove(_userDataKey),
      _prefs!.remove(_tokenExpiryKey),
    ]);
  }

  /// Ensure SharedPreferences is initialized
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Handle authentication errors
  ApiException _handleAuthError(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return ApiException(
          error.response?.data?['message'] ?? 'Invalid request',
          ApiErrorType.badRequest,
        );
      case 401:
        return ApiException(
          'Invalid username or password',
          ApiErrorType.unauthorized,
        );
      case 403:
        return ApiException(
          'Account is disabled or suspended',
          ApiErrorType.forbidden,
        );
      case 422:
        return ValidationException(
          'Validation failed',
          error.response?.data?['errors'] ?? {},
        );
      case 500:
        return ApiException(
          'Server error occurred during authentication',
          ApiErrorType.server,
        );
      default:
        return ApiException(
          'Authentication failed',
          ApiErrorType.unknown,
        );
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