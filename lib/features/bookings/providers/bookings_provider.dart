import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../repositories/bookings_repository.dart';
import '../../../core/network/api_client.dart';

final bookingsRepositoryProvider = Provider<BookingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BookingsRepository(dio);
});

final myBookingsProvider = AsyncNotifierProvider<MyBookingsNotifier, List<BookingModel>>(() {
  return MyBookingsNotifier();
});

class MyBookingsNotifier extends AsyncNotifier<List<BookingModel>> {
  @override
  Future<List<BookingModel>> build() async {
    final repo = ref.read(bookingsRepositoryProvider);
    return repo.getMyBookings();
  }

  Future<void> createBooking(BookingModel booking) async {
    final repo = ref.read(bookingsRepositoryProvider);
    
    // Optimistic update
    state = AsyncData([booking, ...?state.value]);
    
    try {
      await repo.addBooking(booking);
    } catch (e) {
      ref.invalidateSelf(); // Revert on error
      rethrow;
    }
  }

  Future<void> cancelBooking(String id) async {
    final repo = ref.read(bookingsRepositoryProvider);
    final previousState = state;
    
    if (state.value != null) {
      state = AsyncData([
        for (final b in state.value!)
          if (b.id == id) b.copyWith(status: BookingStatus.cancelled) else b
      ]);
    }
    
    try {
      await repo.cancelBooking(id);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }
}
