import 'package:dio/dio.dart';
import 'token_interceptor.dart';
import 'error_interceptor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provides the base URL depending on environment
final baseUrlProvider = Provider<String>((ref) {
  // Using your live cloud backend so the app works anywhere!
  return 'https://rent-hive-app.onrender.com/api';
});

// Provides the Dio client instance
final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(baseUrlProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors
  dio.interceptors.addAll([
    TokenInterceptor(),
    ErrorInterceptor(),
    LogInterceptor(requestBody: true, responseBody: true), // For debugging
  ]);

  return dio;
});
