import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  // Local development fallback to 10.0.2.2 for Android emulator, or localhost for iOS simulator/devices
  static String get baseUrl {
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000/api/v1";
    }
    return "http://localhost:8000/api/v1";
  }

  ApiClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: "access_token");
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Attempt to refresh token
            final refreshToken = await _storage.read(key: "refresh_token");
            if (refreshToken != null) {
              try {
                final refreshResponse = await Dio().post(
                  "$baseUrl/auth/refresh",
                  data: {"refresh_token": refreshToken},
                );
                if (refreshResponse.statusCode == 200) {
                  final newAccess = refreshResponse.data["access_token"];
                  final newRefresh = refreshResponse.data["refresh_token"];
                  
                  await _storage.write(key: "access_token", value: newAccess);
                  await _storage.write(key: "refresh_token", value: newRefresh);
                  
                  // Retry the original request
                  e.requestOptions.headers["Authorization"] = "Bearer $newAccess";
                  final cloneReq = await _dio.fetch(e.requestOptions);
                  return handler.resolve(cloneReq);
                }
              } catch (refreshErr) {
                // Refresh token expired or failed, clear storage
                await _storage.delete(key: "access_token");
                await _storage.delete(key: "refresh_token");
              }
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}

final apiClient = ApiClient();
