enum ListingStatus { available, booked, paused }
enum ItemCondition { newCondition, likeNew, good, fair }

class MyListing {
  final String id;
  final String title;
  final String description;
  final String category;
  final ItemCondition condition;
  final double pricePerDay;
  final double pricePerWeek;
  final double pricePerMonth;
  final double securityDeposit;
  final int quantityAvailable;
  final String pickupAddress;
  final String city;
  final String state;
  final String pincode;
  final DateTime availableFrom;
  final DateTime availableTo;
  final List<String> images;
  final ListingStatus status;
  final int totalViews;
  final int totalBookings;
  final String paymentNumber;

  MyListing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.pricePerMonth,
    required this.securityDeposit,
    required this.quantityAvailable,
    required this.pickupAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.availableFrom,
    required this.availableTo,
    required this.images,
    this.status = ListingStatus.available,
    this.totalViews = 0,
    this.totalBookings = 0,
    this.paymentNumber = '',
  });

  MyListing copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    ItemCondition? condition,
    double? pricePerDay,
    double? pricePerWeek,
    double? pricePerMonth,
    double? securityDeposit,
    int? quantityAvailable,
    String? pickupAddress,
    String? city,
    String? state,
    String? pincode,
    DateTime? availableFrom,
    DateTime? availableTo,
    List<String>? images,
    ListingStatus? status,
    int? totalViews,
    int? totalBookings,
    String? paymentNumber,
  }) {
    return MyListing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      pricePerWeek: pricePerWeek ?? this.pricePerWeek,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      quantityAvailable: quantityAvailable ?? this.quantityAvailable,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      availableFrom: availableFrom ?? this.availableFrom,
      availableTo: availableTo ?? this.availableTo,
      images: images ?? this.images,
      status: status ?? this.status,
      totalViews: totalViews ?? this.totalViews,
      totalBookings: totalBookings ?? this.totalBookings,
      paymentNumber: paymentNumber ?? this.paymentNumber,
    );
  }

  factory MyListing.fromJson(Map<String, dynamic> json) {
    // Helper for condition
    ItemCondition parseCondition(String cond) {
      switch (cond.toLowerCase()) {
        case 'new': return ItemCondition.newCondition;
        case 'like new': return ItemCondition.likeNew;
        case 'good': return ItemCondition.good;
        case 'fair': return ItemCondition.fair;
        default: return ItemCondition.good;
      }
    }

    ListingStatus parseStatus(String stat) {
      switch (stat.toLowerCase()) {
        case 'available': return ListingStatus.available;
        case 'booked': return ListingStatus.booked;
        case 'paused': return ListingStatus.paused;
        default: return ListingStatus.available;
      }
    }

    double parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final rawImages = json['images'] as List?;
    final imagesList = (rawImages != null && rawImages.isNotEmpty)
        ? rawImages.map((e) {
            var s = e.toString().trim();
            if (s.isEmpty) return 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800';
            if (s.contains('/uploads/')) {
              final filename = s.split('/uploads/').last;
              return 'https://rent-hive-app.onrender.com/uploads/$filename';
            }
            if (s.startsWith('http://')) {
              return s.replaceFirst('http://', 'https://');
            }
            if (s.startsWith('https://')) {
              return s;
            }
            return 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800';
          }).toList()
        : <String>['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800'];

    return MyListing(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      condition: parseCondition(json['condition'] ?? ''),
      pricePerDay: parseNum(json['rates']?['daily'] ?? json['pricePerDay']),
      pricePerWeek: parseNum(json['rates']?['weekly'] ?? json['pricePerWeek']),
      pricePerMonth: parseNum(json['rates']?['monthly'] ?? json['pricePerMonth']),
      securityDeposit: parseNum(json['securityDeposit']),
      quantityAvailable: json['quantity'] ?? 1,
      pickupAddress: json['location']?['address'] ?? '',
      city: json['location']?['city'] ?? '',
      state: json['location']?['state'] ?? '',
      pincode: json['location']?['zip'] ?? '',
      availableFrom: DateTime.now(), // Simplified
      availableTo: DateTime.now().add(const Duration(days: 90)),
      images: imagesList,
      status: parseStatus(json['status'] ?? 'available'),
      totalViews: json['totalViews'] ?? 0,
      totalBookings: json['totalRentals'] ?? 0,
      paymentNumber: json['paymentNumber']?.toString() ?? json['owner']?['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    String getConditionStr(ItemCondition cond) {
      switch (cond) {
        case ItemCondition.newCondition: return 'New';
        case ItemCondition.likeNew: return 'Like New';
        case ItemCondition.good: return 'Good';
        case ItemCondition.fair: return 'Fair';
      }
    }

    return {
      'title': title,
      'description': description,
      'category': category,
      'condition': getConditionStr(condition),
      'rates': {
        'daily': pricePerDay,
        'weekly': pricePerWeek,
        'monthly': pricePerMonth,
      },
      'securityDeposit': securityDeposit,
      'quantity': quantityAvailable,
      'paymentNumber': paymentNumber,
      'images': images,
      'location': {
        'address': pickupAddress,
        'city': city,
        'state': state,
        'zip': pincode,
        'coordinates': [0, 0] // Mock default since we aren't handling geocoding on frontend yet
      },
      'status': status.name,
    };
  }
}
