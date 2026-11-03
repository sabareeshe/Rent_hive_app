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
  final String paymentNumber;

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
    this.paymentNumber = '',
  });

  factory RentalItem.fromJson(Map<String, dynamic> json) {
    final id = json['_id'] ?? json['id'] ?? '';
    final rates = json['rates'] is Map ? json['rates'] : null;
    final dailyRate = rates?['daily'] ?? json['pricePerDay'] ?? json['dailyRate'] ?? 0;
    final imagesList = (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [];
    if (imagesList.isEmpty) {
      imagesList.add('https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800');
    }

    String ownerName = 'Verified Owner';
    String ownerAvatar = '';
    String paymentNum = json['paymentNumber']?.toString() ?? '';

    if (json['owner'] is Map) {
      ownerName = json['owner']['name'] ?? json['owner']['username'] ?? 'Verified Owner';
      ownerAvatar = json['owner']['avatarUrl']?.toString() ?? '';
      if (paymentNum.isEmpty && json['owner']['phone'] != null) {
        paymentNum = json['owner']['phone'].toString();
      }
    } else if (json['ownerName'] != null) {
      ownerName = json['ownerName'].toString();
    }

    final stableAvatar = (ownerAvatar.isNotEmpty && !ownerAvatar.contains('pravatar.cc/150'))
        ? ownerAvatar
        : 'https://api.dicebear.com/7.x/bottts/png?seed=${id.isNotEmpty ? id : ownerName}';

    final rawRating = json['averageRating'] ?? json['rating'];
    final parsedRating = (rawRating is num && rawRating > 0)
        ? rawRating.toDouble()
        : 5.0;

    return RentalItem(
      id: id,
      name: json['title'] ?? json['name'] ?? 'Rental Item',
      images: imagesList,
      pricePerDay: (dailyRate is num) ? dailyRate.toDouble() : (double.tryParse(dailyRate.toString()) ?? 10.0),
      rating: parsedRating,
      reviewsCount: json['totalReviews'] ?? json['reviewsCount'] ?? 1,
      distance: ((json['distance'] ?? 2.5) as num).toDouble(),
      ownerName: ownerName,
      ownerAvatar: stableAvatar,
      category: json['category'] ?? 'General',
      paymentNumber: paymentNum,
    );
  }
}
