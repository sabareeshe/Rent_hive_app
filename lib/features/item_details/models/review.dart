class ReviewModel {
  final String id;
  final String itemId;
  final String authorName;
  final String authorAvatarUrl;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> images;

  ReviewModel({
    required this.id,
    required this.itemId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images = const [],
  });
}

// Mock Reviews for the UI
final List<ReviewModel> mockReviews = [
  ReviewModel(
    id: 'r1',
    itemId: 'l1', // Matches Sony Camera in mock listings
    authorName: 'Sarah Jenkins',
    authorAvatarUrl: 'https://i.pravatar.cc/150?u=sarah',
    rating: 5.0,
    comment: 'Camera was in pristine condition. Owner was very communicative and flexible with pickup times. Highly recommend for any weekend shoots!',
    createdAt: DateTime.now().subtract(const Duration(days: 4)),
    images: ['https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=300&auto=format&fit=crop'],
  ),
  ReviewModel(
    id: 'r2',
    itemId: 'l1',
    authorName: 'Mike Ross',
    authorAvatarUrl: 'https://i.pravatar.cc/150?u=mike',
    rating: 4.5,
    comment: 'Great camera. Battery lasted all day. The only minor issue was finding the pickup location, but the owner guided me well.',
    createdAt: DateTime.now().subtract(const Duration(days: 12)),
  ),
  ReviewModel(
    id: 'r3',
    itemId: 'l1',
    authorName: 'Emily Chen',
    authorAvatarUrl: 'https://i.pravatar.cc/150?u=emily',
    rating: 5.0,
    comment: 'Perfect transaction. Will rent again!',
    createdAt: DateTime.now().subtract(const Duration(days: 25)),
  ),
];
