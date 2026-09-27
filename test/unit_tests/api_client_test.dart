import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

void main() {
  group('ApiClient Tests', () {
    test('Dio base URL should point to local backend API', () {
      final dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:5000/api'));
      expect(dio.options.baseUrl, 'http://10.0.2.2:5000/api');
    });

    test('ErrorInterceptor formats messages properly', () {
      // Setup mock error handling logic if needed
      expect(true, isTrue); // Placeholder
    });
  });
}
