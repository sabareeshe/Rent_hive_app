enum NotificationType { booking, message, reminder, system }

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.timestamp,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? timestamp,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType parseType(String type) {
      switch (type.toLowerCase()) {
        case 'booking': return NotificationType.booking;
        case 'message': return NotificationType.message;
        case 'reminder': return NotificationType.reminder;
        default: return NotificationType.system;
      }
    }

    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'Notification',
      body: json['message'] ?? '',
      type: parseType(json['type'] ?? 'system'),
      isRead: json['isRead'] ?? false,
      timestamp: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
