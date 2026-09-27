class UserModel {
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final String bio;
  final String city;
  final String state;
  final String pincode;
  final DateTime memberSince;
  final bool isVerified;
  final double averageRating;
  final int totalReviews;
  final int totalListings;
  final int totalRentals;

  UserModel({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.bio,
    required this.city,
    required this.state,
    required this.pincode,
    required this.memberSince,
    required this.isVerified,
    required this.averageRating,
    required this.totalReviews,
    required this.totalListings,
    required this.totalRentals,
  });

  UserModel copyWith({
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? bio,
    String? city,
    String? state,
    String? pincode,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      memberSince: memberSince,
      isVerified: isVerified,
      averageRating: averageRating,
      totalReviews: totalReviews,
      totalListings: totalListings,
      totalRentals: totalRentals,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      fullName: json['name'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone'] ?? '',
      avatarUrl: json['avatarUrl'] ?? 'https://i.pravatar.cc/150',
      bio: json['bio'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      memberSince: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      totalListings: json['totalListings'] ?? 0,
      totalRentals: json['totalRentals'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'username': username,
      'phone': phoneNumber,
      'bio': bio,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}
