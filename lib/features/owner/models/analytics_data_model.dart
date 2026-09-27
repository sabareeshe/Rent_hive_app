class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint(this.label, this.value);

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      json['label'] ?? '',
      (json['value'] ?? 0).toDouble(),
    );
  }
}

class AnalyticsDataModel {
  final List<ChartDataPoint> revenueTimeline;
  final List<ChartDataPoint> bookingTrends;
  final List<ChartDataPoint> topCategories;
  final List<ChartDataPoint> listingPerformance;

  AnalyticsDataModel({
    required this.revenueTimeline,
    required this.bookingTrends,
    required this.topCategories,
    required this.listingPerformance,
  });

  factory AnalyticsDataModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsDataModel(
      revenueTimeline: (json['revenueTimeline'] as List?)?.map((x) => ChartDataPoint.fromJson(x)).toList() ?? [],
      bookingTrends: (json['bookingTrends'] as List?)?.map((x) => ChartDataPoint.fromJson(x)).toList() ?? [],
      topCategories: (json['topCategories'] as List?)?.map((x) => ChartDataPoint.fromJson(x)).toList() ?? [],
      listingPerformance: (json['listingPerformance'] as List?)?.map((x) => ChartDataPoint.fromJson(x)).toList() ?? [],
    );
  }
}
