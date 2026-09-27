class RentalItem {
  final String id;
  final String name;
  final List<String> images;
  final double pricePerDay;
  final double rating;
  final int reviewsCount;
  final double distance;
  final String ownerName;
  final String ownerAvatar;
  final String category;

  RentalItem({
    required this.id,
    required this.name,
    required this.images,
    required this.pricePerDay,
    required this.rating,
    required this.reviewsCount,
    required this.distance,
    required this.ownerName,
    required this.ownerAvatar,
    required this.category,
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    return RentalItem(
      id: json['_id'] ?? '',
      name: json['title'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      pricePerDay: (json['rates']?['daily'] ?? 0).toDouble(),
      rating: (json['averageRating'] ?? 0).toDouble(),
      reviewsCount: json['totalReviews'] ?? 0,
      distance: 5.0, // Mock distance
      ownerName: json['owner'] is Map ? json['owner']['name'] ?? 'Owner' : 'Owner',
      ownerAvatar: json['owner'] is Map ? json['owner']['avatarUrl'] ?? 'https://i.pravatar.cc/150' : 'https://i.pravatar.cc/150',
      category: json['category'] ?? '',
    );
  }
}
