import 'package:dio/dio.dart';
import '../models/dashboard_stats_model.dart';

class OwnerRepository {
  final Dio _dio;
  OwnerRepository(this._dio);

  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _dio.get('/owner/dashboard/stats');
      return DashboardStatsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> generateReport(String type) async {
    // Generate report logic, mock for now since it's not a core API
    await Future.delayed(const Duration(seconds: 2));
  }
}
