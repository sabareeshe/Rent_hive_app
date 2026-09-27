import 'package:dio/dio.dart';
import '../models/analytics_data_model.dart';

class AnalyticsRepository {
  final Dio _dio;
  AnalyticsRepository(this._dio);

  Future<AnalyticsDataModel> getAnalytics(String filter) async {
    try {
      final response = await _dio.get('/owner/analytics', queryParameters: {'filter': filter});
      return AnalyticsDataModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
