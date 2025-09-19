import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:math';
import '../config/api_config.dart';
import '../exceptions/api_exceptions.dart';
import 'auth_service.dart';

/// Service for handling HTTP requests to PostgreSQL backend
class ApiService {
  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();
  ApiService._();

  late final Dio _dio;
  final AuthService _authService = AuthService.instance;
  
  bool _isInitialized = false;

  /// Initialize the API service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
      headers: ApiConfig.defaultHeaders,
    ));

    // Add interceptors
    _addInterceptors();
    
    _isInitialized = true;
  }

  /// Add request/response interceptors
  void _addInterceptors() {
    // Request interceptor for authentication
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _authService.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        // Disable caching during development
        if (kDebugMode) {
          options.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate';
          options.headers['Pragma'] = 'no-cache';
          options.headers['Expires'] = '0';
        }
        
        if (kDebugMode) {
          print('🚀 API Request: ${options.method} ${options.path}');
          print('📤 Headers: ${options.headers}');
          if (options.data != null) {
            print('📤 Data: ${options.data}');
          }
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
          print('📥 Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('❌ Error: ${error.message}');
        }

        // Handle token refresh for 401 errors
        if (error.response?.statusCode == 401) {
          try {
            final refreshed = await _authService.refreshToken();
            if (refreshed) {
              // Retry the original request
              final token = await _authService.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            }
          } catch (e) {
            // Refresh failed, logout user
            await _authService.logout();
          }
        }
        
        handler.next(error);
      },
    ));

    // Retry interceptor
    _dio.interceptors.add(RetryInterceptor());
  }

  /// Check network connectivity
  Future<bool> _isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Generic GET request
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      if (!await _isConnected()) {
        throw ApiException('No internet connection', ApiErrorType.network);
      }

      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic POST request
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      if (!await _isConnected()) {
        throw ApiException('No internet connection', ApiErrorType.network);
      }

      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic PUT request
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      if (!await _isConnected()) {
        throw ApiException('No internet connection', ApiErrorType.network);
      }

      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic DELETE request
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool requiresAuth = true,
  }) async {
    try {
      if (!await _isConnected()) {
        throw ApiException('No internet connection', ApiErrorType.network);
      }

      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle successful response
  T _handleResponse<T>(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data as T;
    } else {
      throw ApiException(
        'Request failed with status: ${response.statusCode}',
        ApiErrorType.server,
      );
    }
  }

  /// Handle Dio errors and convert to ApiException
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Request timeout', ApiErrorType.timeout);
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        
        switch (statusCode) {
          case 400:
            return ApiException(message, ApiErrorType.badRequest);
          case 401:
            return ApiException('Unauthorized', ApiErrorType.unauthorized);
          case 403:
            return ApiException('Forbidden', ApiErrorType.forbidden);
          case 404:
            return ApiException('Not found', ApiErrorType.notFound);
          case 422:
            return ApiException(message, ApiErrorType.validation);
          case 500:
            return ApiException('Internal server error', ApiErrorType.server);
          default:
            return ApiException(message, ApiErrorType.server);
        }
      
      case DioExceptionType.cancel:
        return ApiException('Request cancelled', ApiErrorType.cancelled);
      
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return ApiException('Network error', ApiErrorType.network);
    }
  }

  /// Upload file
  Future<T> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      if (!await _isConnected()) {
        throw ApiException('No internet connection', ApiErrorType.network);
      }

      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return _handleResponse<T>(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Download file
  Future<void> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      if (!await _isConnected()) {
        throw ApiException('No internet connection', ApiErrorType.network);
      }

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}

/// Retry interceptor for handling failed requests
class RetryInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Retry failed, continue with original error
        if (kDebugMode) {
          print('❌ Retry failed after ${ApiConfig.maxRetries} attempts: $e');
        }
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Don't retry authentication errors (401, 403) to avoid account lockouts
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      return false;
    }
    
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      headers: ApiConfig.defaultHeaders,
    ));
    
    for (int i = 0; i < ApiConfig.maxRetries; i++) {
      try {
        // Exponential backoff with jitter
        final delay = (ApiConfig.retryDelay * pow(2, i)).toInt() + Random().nextInt(1000);
        await Future.delayed(Duration(milliseconds: delay));
        
        if (kDebugMode) {
          print('🔄 Retry attempt ${i + 1}/${ApiConfig.maxRetries} for ${requestOptions.path}');
        }
        
        return await dio.fetch(requestOptions);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Retry ${i + 1} failed: $e');
        }
        if (i == ApiConfig.maxRetries - 1) rethrow;
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}