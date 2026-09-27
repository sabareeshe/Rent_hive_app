import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/review_model.dart';
import '../models/settings_model.dart';

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
    // In a real app, you might have a public endpoint: /users/:id
    // Here we'll just mock it or assume the backend has it.
    // For now we will mock since we didn't build a public profile backend endpoint.
    return UserModel(
      id: userId,
      fullName: 'Public User',
      username: '@user',
      email: '',
      phoneNumber: '',
      avatarUrl: 'https://i.pravatar.cc/150?u=$userId',
      bio: 'Trusted on RentHive.',
      city: '',
      state: '',
      pincode: '',
      memberSince: DateTime.now().subtract(const Duration(days: 500)),
      isVerified: true,
      averageRating: 4.9,
      totalReviews: 120,
      totalListings: 15,
      totalRentals: 0,
    );
  }

  Future<UserModel> updateProfile(UserModel updatedUser, {String? imagePath}) async {
    FormData? formData;
    
    if (imagePath != null) {
      formData = FormData.fromMap({
        ...updatedUser.toJson(),
        'avatar': await MultipartFile.fromFile(imagePath, filename: 'avatar.jpg'),
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
    return SettingsModel();
  }

  Future<void> updateSettings(SettingsModel settings) async {
    // mock update
  }
}
