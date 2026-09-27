import 'package:dio/dio.dart';
import '../models/earnings_model.dart';

class EarningsRepository {
  final Dio _dio;
  EarningsRepository(this._dio);

  Future<EarningsModel> getEarnings() async {
    try {
      final response = await _dio.get('/owner/earnings');
      return EarningsModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestWithdrawal(double amount, String details) async {
    try {
      await _dio.post('/owner/withdraw', data: {
        'amount': amount,
        'details': details,
      });
    } catch (e) {
      rethrow;
    }
  }
}
