import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    // Save token
    final token = response.data['token'];
    if (token != null) {
      await _secureStorage.write(key: 'jwt_token', value: token);
    }
    
    return response.data;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/auth/register', data: {
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'role': 'renter',
    });
    
    // Save token
    final token = response.data['token'];
    if (token != null) {
      await _secureStorage.write(key: 'jwt_token', value: token);
    }

    return response.data;
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'jwt_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_profile');
    await prefs.remove('cached_my_listings');
  }

  Future<bool> checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    return token != null;
  }

  Future<void> forgotPassword(String email) async {
    await _dio.post('/auth/forgotpassword', data: {
      'email': email,
    });
  }
}
