import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../models/booking.dart';
import '../providers/bookings_provider.dart';
import '../widgets/booking_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: bookingsState.when(
        data: (bookings) {
          final upcoming = bookings.where((b) => b.status == BookingStatus.upcoming).toList();
          final active = bookings.where((b) => b.status == BookingStatus.active).toList();
          final completed = bookings.where((b) => b.status == BookingStatus.completed).toList();
          final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBookingsList(upcoming, 'No upcoming bookings.'),
              _buildBookingsList(active, 'No active bookings.'),
              _buildBookingsList(completed, 'No completed bookings.'),
              _buildBookingsList(cancelled, 'No cancelled bookings.'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
          ],
        ).animate().fadeIn(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return BookingCard(
          booking: list[index],
          onTap: () {
            context.push('${AppRouter.bookingDetails}?id=${list[index].id}');
          },
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1);
      },
    );
  }
}
