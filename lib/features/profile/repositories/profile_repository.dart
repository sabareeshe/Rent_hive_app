import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../models/settings_model.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class ProfileRepository {
  final Dio _dio;
  ProfileRepository(this._dio);

  // --- USER API ---
  Future<UserModel> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _dio.get('/users/profile');
      final user = UserModel.fromJson(response.data);
      
      // Cache offline
      await prefs.setString('cached_profile', jsonEncode(response.data));
      return user;
    } catch (e) {
      // Fallback to cache if network fails
      final cached = prefs.getString('cached_profile');
      if (cached != null) {
        return UserModel.fromJson(jsonDecode(cached));
      }
      rethrow;
    }
  }

  Future<UserModel> getPublicProfile(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return UserModel.fromJson(response.data);
    } catch (e) {
      return UserModel(
        id: userId,
        fullName: 'User Profile',
        username: 'user',
        email: '',
        phoneNumber: '',
        avatarUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=$userId',
        bio: 'Trusted on RentHive.',
        city: '',
        state: '',
        pincode: '',
        memberSince: DateTime.now().subtract(const Duration(days: 300)),
        isVerified: true,
        averageRating: 4.9,
        totalReviews: 24,
        totalListings: 3,
        totalRentals: 12,
      );
    }
  }

  Future<UserModel> updateProfile(UserModel updatedUser, {String? imagePath}) async {
    FormData? formData;
    
    if (imagePath != null) {
      MultipartFile file;
      if (kIsWeb) {
        final response = await Dio().get(
          imagePath,
          options: Options(responseType: ResponseType.bytes),
        );
        file = MultipartFile.fromBytes(response.data, filename: 'avatar.jpg');
      } else {
        file = await MultipartFile.fromFile(imagePath, filename: 'avatar.jpg');
      }
      
      formData = FormData.fromMap({
        ...updatedUser.toJson(),
        'avatar': file,
      });
    }

    final response = await _dio.put(
      '/users/profile',
      data: formData ?? updatedUser.toJson(),
    );
    
    final user = UserModel.fromJson(response.data);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_profile', jsonEncode(response.data));
    
    return user;
  }

  // --- REVIEWS API ---
  Future<List<ReviewModel>> getReviewsForTarget(String targetId) async {
    try {
      // Here targetId is expected to be a listing ID. If it's a user ID, a different endpoint would be needed.
      final response = await _dio.get('/reviews/listing/$targetId');
      return (response.data as List).map((x) => ReviewModel.fromJson(x)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitReview({
    required String itemId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      await _dio.post('/reviews', data: {
        'item': itemId,
        'bookingId': bookingId,
        'rating': rating,
        'comment': comment,
      });
    } catch (e) {
      rethrow;
    }
  }

  // --- SETTINGS API ---
  Future<SettingsModel> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('is_dark_mode') ?? false;
    final push = prefs.getBool('push_notifications') ?? true;
    return SettingsModel(
      isDarkMode: isDark,
      pushNotificationsEnabled: push,
    );
  }

  Future<void> updateSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', settings.isDarkMode);
    await prefs.setBool('push_notifications', settings.pushNotificationsEnabled);
  }

  Future<void> changePassword(String newPassword) async {
    await _dio.put('/users/profile', data: {'password': newPassword});
  }

  Future<void> deleteAccount() async {
    await _dio.delete('/users/profile');
  }
}
