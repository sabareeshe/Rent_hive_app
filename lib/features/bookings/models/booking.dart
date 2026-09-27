enum BookingStatus { upcoming, active, completed, cancelled }

class BookingModel {
  final String id;
  final String itemId;
  final String ownerId;
  final String renterId;
  final DateTime startDate;
  final DateTime endDate;
  final int rentalDays;
  final double rentalCost;
  final double securityDeposit;
  final double platformFee;
  final double tax;
  final double grandTotal;
  final BookingStatus status;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.itemId,
    required this.ownerId,
    required this.renterId,
    required this.startDate,
    required this.endDate,
    required this.rentalDays,
    required this.rentalCost,
    required this.securityDeposit,
    required this.platformFee,
    required this.tax,
    required this.grandTotal,
    required this.status,
    required this.createdAt,
  });

  BookingModel copyWith({
    String? id,
    String? itemId,
    String? ownerId,
    String? renterId,
    DateTime? startDate,
    DateTime? endDate,
    int? rentalDays,
    double? rentalCost,
    double? securityDeposit,
    double? platformFee,
    double? tax,
    double? grandTotal,
    BookingStatus? status,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      ownerId: ownerId ?? this.ownerId,
      renterId: renterId ?? this.renterId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rentalDays: rentalDays ?? this.rentalDays,
      rentalCost: rentalCost ?? this.rentalCost,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      platformFee: platformFee ?? this.platformFee,
      tax: tax ?? this.tax,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    BookingStatus parseStatus(String stat) {
      switch (stat.toLowerCase()) {
        case 'pending': return BookingStatus.upcoming;
        case 'approved': return BookingStatus.upcoming;
        case 'active': return BookingStatus.active;
        case 'completed': return BookingStatus.completed;
        case 'cancelled': return BookingStatus.cancelled;
        default: return BookingStatus.upcoming;
      }
    }

    return BookingModel(
      id: json['_id'] ?? '',
      itemId: json['item'] is Map ? json['item']['_id'] ?? '' : json['item'] ?? '',
      ownerId: json['owner'] is Map ? json['owner']['_id'] ?? '' : json['owner'] ?? '',
      renterId: json['renter'] is Map ? json['renter']['_id'] ?? '' : json['renter'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : DateTime.now(),
      rentalDays: json['totalDays'] ?? 1,
      rentalCost: (json['price'] ?? 0).toDouble(),
      securityDeposit: (json['securityDeposit'] ?? 0).toDouble(),
      platformFee: (json['platformFee'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      grandTotal: (json['totalAmount'] ?? 0).toDouble(),
      status: parseStatus(json['status'] ?? 'pending'),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': itemId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
