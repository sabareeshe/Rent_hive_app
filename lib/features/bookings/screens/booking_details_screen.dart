import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/booking.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../providers/bookings_provider.dart';
import '../../../core/theme/app_colors.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  ConsumerState<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final bookingsState = ref.watch(myBookingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Details'),
      ),
      body: bookingsState.when(
        data: (bookings) {
          final booking = bookings.firstWhere(
            (b) => b.id == widget.bookingId,
            orElse: () => bookings.first,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(booking),
                const SizedBox(height: 32),
                _buildTimeline(booking),
                const Divider(height: 48),
                _buildInvoice(booking),
                const Divider(height: 48),
                _buildActions(booking),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatusHeader(BookingModel booking) {
    IconData icon;
    Color color;
    String statusText;

    switch (booking.status) {
      case BookingStatus.upcoming:
        icon = Icons.event;
        color = Colors.blue;
        statusText = 'Upcoming Booking';
        break;
      case BookingStatus.active:
        icon = Icons.directions_run;
        color = Colors.green;
        statusText = 'Active Rental';
        break;
      case BookingStatus.completed:
        icon = Icons.check_circle;
        color = Colors.purple;
        statusText = 'Completed';
        break;
      case BookingStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.red;
        statusText = 'Cancelled';
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(statusText, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text('ID: #${booking.id}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeline(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rental Timeline', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildTimelineTile(
          title: 'Pickup',
          subtitle: DateFormat('EEEE, MMM d, yyyy').format(booking.startDate),
          icon: Icons.upload,
          isFirst: true,
          isActive: booking.status != BookingStatus.cancelled,
        ),
        _buildTimelineTile(
          title: 'Return',
          subtitle: DateFormat('EEEE, MMM d, yyyy').format(booking.endDate),
          icon: Icons.download,
          isLast: true,
          isActive: booking.status == BookingStatus.completed,
        ),
      ],
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
    bool isActive = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: isActive ? Colors.white : Colors.grey),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? AppColors.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvoice(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Invoice', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              _buildPriceRow('Rental Cost (${booking.rentalDays} days)', '\$${booking.rentalCost.toStringAsFixed(2)}'),
              _buildPriceRow('Platform Fee', '\$${booking.platformFee.toStringAsFixed(2)}'),
              _buildPriceRow('Tax', '\$${booking.tax.toStringAsFixed(2)}'),
              _buildPriceRow('Security Deposit (Refundable)', '\$${booking.securityDeposit.toStringAsFixed(2)}'),
              const Divider(height: 24),
              _buildPriceRow('Grand Total', '\$${booking.grandTotal.toStringAsFixed(2)}', isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BookingModel booking) {
    return Column(
      children: [
        if (booking.status == BookingStatus.upcoming)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showCancelDialog(context, booking.id);
              },
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text('Cancel Booking', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        if (booking.status == BookingStatus.completed)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('${AppRouter.writeReview}?targetId=${booking.itemId}'),
              icon: const Icon(Icons.star_outline),
              label: const Text('Leave a Review'),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              context.push('${AppRouter.chat}?id=c_new&name=${Uri.encodeComponent('Owner')}');
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat with Owner'),
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel? Refund policies apply.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep it'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(myBookingsProvider.notifier).cancelBooking(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
