import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenInterceptor extends Interceptor {
  final _secureStorage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _secureStorage.read(key: 'jwt_token');

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If the server returns a 401 Unauthorized, we might want to log out the user
    // or attempt a token refresh here.
    if (err.response?.statusCode == 401) {
      // Clear token
      await _secureStorage.delete(key: 'jwt_token');
      // Ideally, trigger a broadcast to navigate to LoginScreen
    }

    super.onError(err, handler);
  }
}
