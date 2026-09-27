import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/router/app_router.dart';
import '../../home/models/rental_item.dart';
import '../../home/data/mock_rentals.dart';
import '../models/booking.dart';
import '../providers/bookings_provider.dart';
import '../providers/booking_calculator_provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BookingSummaryScreen extends ConsumerStatefulWidget {
  final String itemId;
  final DateTime startDate;
  final DateTime endDate;

  const BookingSummaryScreen({
    super.key,
    required this.itemId,
    required this.startDate,
    required this.endDate,
  });

  @override
  ConsumerState<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends ConsumerState<BookingSummaryScreen> {
  late RentalItem item;
  bool _isProcessing = false;
  late Razorpay _razorpay;
  late String _bookingId;

  @override
  void initState() {
    super.initState();
    item = mockRentals.firstWhere(
      (element) => element.id == widget.itemId,
      orElse: () => mockRentals.first,
    );

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // Payment succeeded, now save booking to backend
    try {
      final calculation = ref.read(bookingCalculationStateProvider);
      final newBooking = BookingModel(
        id: _bookingId,
        itemId: item.id,
        ownerId: item.ownerName, // Mock
        renterId: 'current_user',
        startDate: widget.startDate,
        endDate: widget.endDate,
        rentalDays: calculation.rentalDays,
        rentalCost: calculation.baseCost,
        securityDeposit: calculation.securityDeposit,
        platformFee: calculation.platformFee,
        tax: calculation.tax,
        grandTotal: calculation.grandTotal,
        status: BookingStatus.upcoming,
        createdAt: DateTime.now(),
      );

      await ref.read(myBookingsProvider.notifier).createBooking(newBooking);
      if (mounted) {
        context.go('${AppRouter.bookingConfirmation}?bookingId=$_bookingId');
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment succeeded but booking failed.')),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  Future<void> _confirmBooking() async {
    setState(() => _isProcessing = true);

    final calculation = BookingCalculator.calculate(
      CalculationParams(pricePerDay: item.pricePerDay, securityDeposit: 150.0),
      widget.startDate,
      widget.endDate,
    );
    ref.read(bookingCalculationStateProvider.notifier).update(calculation);

    _bookingId = DateTime.now().millisecondsSinceEpoch.toString();

    var options = {
      'key': 'rzp_test_YourTestKey',
      'amount': (calculation.grandTotal * 100).toInt(), // amount in the smallest currency sub-unit (e.g., paise for INR)
      'name': 'RentHive',
      'description': 'Booking for ${item.name}',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@renthive.com'
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to open payment gateway.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(bookingCalculationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm and Pay'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item snapshot
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.images.first,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${item.rating} (${item.reviewsCount})'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Owner: ${item.ownerName}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 48),
            
            Text('Your Trip', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dates', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Edit'),
                ),
              ],
            ),
            Text('${widget.startDate.day}/${widget.startDate.month}/${widget.startDate.year} - ${widget.endDate.day}/${widget.endDate.month}/${widget.endDate.year}'),
            
            const Divider(height: 48),

            Text('Price Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPriceRow('Total Cost', '\$${calculation.grandTotal.toStringAsFixed(2)}', isTotal: true),
            
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: Colors.blue),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text('Your payment is secure and the security deposit is held safely until the item is returned.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _confirmBooking,
            child: _isProcessing
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Confirm Booking'),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
