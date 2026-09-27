import 'package:dio/dio.dart';
import '../models/booking.dart';

class BookingsRepository {
  final Dio _dio;
  BookingsRepository(this._dio);

  Future<List<BookingModel>> getMyBookings() async {
    try {
      final response = await _dio.get('/bookings/my-bookings');
      return (response.data as List).map((x) => BookingModel.fromJson(x)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<BookingModel> addBooking(BookingModel booking) async {
    try {
      final response = await _dio.post('/bookings', data: booking.toJson());
      return BookingModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelBooking(String id) async {
    try {
      await _dio.put('/bookings/$id/status', data: {'status': 'cancelled'});
    } catch (e) {
      rethrow;
    }
  }
}
