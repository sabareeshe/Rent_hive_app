import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/chat_model.dart';
import '../models/notification_model.dart';
import '../../home/models/rental_item.dart';

class EngagementRepository {
  final Dio _dio;
  EngagementRepository(this._dio);

  // --- WISHLIST API ---
  Future<List<RentalItem>> getWishlistItems() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final response = await _dio.get('/wishlist');
      // The backend returns a wishlist document with 'items' array populated
      final items = response.data['items'] as List? ?? [];
      final list = items.map((x) => RentalItem.fromJson(x)).toList();
      
      await prefs.setString('cached_wishlist', jsonEncode(items));
      return list;
    } catch (e) {
      final cached = prefs.getString('cached_wishlist');
      if (cached != null) {
        return (jsonDecode(cached) as List).map((x) => RentalItem.fromJson(x)).toList();
      }
      rethrow;
    }
  }

  Future<void> toggleWishlist(String itemId) async {
    try {
      // Adding for now. A real toggle would check if it exists or backend would handle it.
      await _dio.post('/wishlist/$itemId');
    } catch (e) {
      // If it fails, maybe it already exists or it's a delete operation. We can try delete if post fails.
      try {
        await _dio.delete('/wishlist/$itemId');
      } catch (_) {
        rethrow;
      }
    }
  }

  Future<bool> isInWishlist(String itemId) async {
    // Need to fetch full wishlist to check, or rely on a specific endpoint
    final items = await getWishlistItems();
    return items.any((item) => item.id == itemId);
  }

  // --- CHAT API ---
  Future<List<ConversationModel>> getConversations(String currentUserId) async {
    try {
      final response = await _dio.get('/chat/conversations');
      return (response.data as List).map((x) => ConversationModel.fromJson(x, currentUserId)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get('/chat/conversations/$conversationId/messages');
      return (response.data as List).map((x) => MessageModel.fromJson(x)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMessage(String receiverId, String itemId, String text) async {
    try {
      await _dio.post('/chat/messages', data: {
        'receiverId': receiverId,
        'itemId': itemId,
        'text': text,
      });
    } catch (e) {
      rethrow;
    }
  }

  // --- NOTIFICATIONS API ---
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      return (response.data as List).map((x) => NotificationModel.fromJson(x)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _dio.put('/notifications/$id/read');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(String id) async {
    // Assuming a delete endpoint exists or we ignore
  }
}
