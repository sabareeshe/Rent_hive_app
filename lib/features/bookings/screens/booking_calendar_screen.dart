import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/models/rental_item.dart';
import '../../home/data/mock_rentals.dart';
import '../providers/booking_calculator_provider.dart';

class BookingCalendarScreen extends ConsumerStatefulWidget {
  final String itemId;

  const BookingCalendarScreen({super.key, required this.itemId});

  @override
  ConsumerState<BookingCalendarScreen> createState() => _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends ConsumerState<BookingCalendarScreen> {
  late RentalItem item;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    item = mockRentals.firstWhere(
      (element) => element.id == widget.itemId,
      orElse: () => mockRentals.first,
    );
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });

      final calc = BookingCalculator.calculate(
        CalculationParams(pricePerDay: item.pricePerDay, securityDeposit: 150.0),
        picked.start,
        picked.end,
      );
      ref.read(bookingCalculationStateProvider.notifier).update(calc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculation = ref.watch(bookingCalculationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Dates'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selected Dates Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Start Date', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            _startDate != null ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}' : 'Select',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('End Date', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text(
                            _endDate != null ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}' : 'Select',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.calendar_month),
                label: const Text('Open Calendar'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            if (calculation.rentalDays > 0) ...[
              const SizedBox(height: 32),
              Text(
                'Price Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildPriceRow('\$${item.pricePerDay} x ${calculation.rentalDays} nights', '\$${calculation.baseCost.toStringAsFixed(2)}'),
              _buildPriceRow('Platform Fee (10%)', '\$${calculation.platformFee.toStringAsFixed(2)}'),
              _buildPriceRow('Taxes (8%)', '\$${calculation.tax.toStringAsFixed(2)}'),
              _buildPriceRow('Security Deposit', '\$${calculation.securityDeposit.toStringAsFixed(2)}'),
              const Divider(height: 32),
              _buildPriceRow('Total', '\$${calculation.grandTotal.toStringAsFixed(2)}', isTotal: true),
            ],
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ElevatedButton(
            onPressed: calculation.rentalDays > 0
                ? () {
                    // Navigate to summary screen
                    context.push(
                      '${AppRouter.bookingSummary}?itemId=${item.id}&start=${_startDate!.toIso8601String()}&end=${_endDate!.toIso8601String()}',
                    );
                  }
                : null,
            child: const Text('Proceed to Checkout'),
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
