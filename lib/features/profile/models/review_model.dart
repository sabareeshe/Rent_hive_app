class ReviewModel {
  final String id;
  final String targetId; // itemId or userId
  final String reviewerId;
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String comment;
  final List<String> images;
  final DateTime timestamp;

  ReviewModel({
    required this.id,
    required this.targetId,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.rating,
    required this.comment,
    this.images = const [],
    required this.timestamp,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? '',
      targetId: json['item'] ?? json['targetUser'] ?? '',
      reviewerId: json['author'] is Map ? json['author']['_id'] ?? '' : json['author'] ?? '',
      reviewerName: json['author'] is Map ? json['author']['name'] ?? 'User' : 'User',
      reviewerAvatar: json['author'] is Map ? json['author']['avatarUrl'] ?? 'https://i.pravatar.cc/150' : 'https://i.pravatar.cc/150',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      timestamp: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
