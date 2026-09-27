class DashboardStatsModel {
  final double totalEarnings;
  final int activeListings;
  final int activeRentals;
  final int pendingRequests;
  final int completedRentals;
  final double monthlyRevenue;
  final double averageRating;

  DashboardStatsModel({
    required this.totalEarnings,
    required this.activeListings,
    required this.activeRentals,
    required this.pendingRequests,
    required this.completedRentals,
    required this.monthlyRevenue,
    required this.averageRating,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalEarnings: (json['totalEarnings'] ?? 0).toDouble(),
      activeListings: json['activeListings'] ?? 0,
      activeRentals: json['activeRentals'] ?? 0,
      pendingRequests: json['pendingRequests'] ?? 0,
      completedRentals: json['completedRentals'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      averageRating: (json['averageRating'] ?? 0).toDouble(),
    );
  }
}
