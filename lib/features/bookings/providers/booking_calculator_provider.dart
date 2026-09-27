import 'package:flutter_riverpod/flutter_riverpod.dart';

// State to hold the calculated values
class BookingCalculation {
  final int rentalDays;
  final double baseCost;
  final double securityDeposit;
  final double platformFee;
  final double tax;
  final double grandTotal;

  BookingCalculation({
    required this.rentalDays,
    required this.baseCost,
    required this.securityDeposit,
    required this.platformFee,
    required this.tax,
    required this.grandTotal,
  });

  factory BookingCalculation.empty() {
    return BookingCalculation(
      rentalDays: 0,
      baseCost: 0,
      securityDeposit: 0,
      platformFee: 0,
      tax: 0,
      grandTotal: 0,
    );
  }
}

// Params needed to calculate
class CalculationParams {
  final double pricePerDay;
  final double securityDeposit;

  CalculationParams({
    required this.pricePerDay,
    required this.securityDeposit,
  });
}

class BookingCalculationNotifier extends Notifier<BookingCalculation> {
  @override
  BookingCalculation build() => BookingCalculation.empty();

  void update(BookingCalculation calc) {
    state = calc;
  }
}

final bookingCalculationStateProvider = NotifierProvider<BookingCalculationNotifier, BookingCalculation>(
  BookingCalculationNotifier.new,
);

class BookingCalculator {
  static BookingCalculation calculate(CalculationParams params, DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return BookingCalculation.empty();
    }

    final difference = end.difference(start).inDays;
    final int rentalDays = difference >= 0 ? difference + 1 : 0;

    if (rentalDays == 0) {
      return BookingCalculation.empty();
    }

    final double baseCost = rentalDays * params.pricePerDay;
    final double platformFee = baseCost * 0.10;
    final double tax = baseCost * 0.08;

    final double grandTotal = baseCost + params.securityDeposit + platformFee + tax;

    return BookingCalculation(
      rentalDays: rentalDays,
      baseCost: baseCost,
      securityDeposit: params.securityDeposit,
      platformFee: platformFee,
      tax: tax,
      grandTotal: grandTotal,
    );
  }
}
