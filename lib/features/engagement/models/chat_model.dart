class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? '',
      senderId: json['senderId'] is Map ? json['senderId']['_id'] ?? '' : json['senderId'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}

class ConversationModel {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final MessageModel? lastMessage;
  final int unreadCount;
  final bool isOnline;

  ConversationModel({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    this.lastMessage,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Assuming backend participants is an array of users, find the other user
    final participants = json['participants'] as List? ?? [];
    var otherUser = participants.firstWhere((p) => p['_id'] != currentUserId, orElse: () => null);
    otherUser ??= {};

    return ConversationModel(
      id: json['_id'] ?? '',
      otherUserId: otherUser['_id'] ?? '',
      otherUserName: otherUser['name'] ?? 'User',
      otherUserAvatar: otherUser['avatarUrl'] ?? 'https://i.pravatar.cc/150',
      lastMessage: json['lastMessage'] != null ? MessageModel(
        id: '', senderId: '', text: json['lastMessage'], timestamp: DateTime.now()
      ) : null,
      unreadCount: 0,
      isOnline: false, // Could implement websocket status later
    );
  }
}
