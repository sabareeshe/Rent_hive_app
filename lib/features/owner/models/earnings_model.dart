enum TransactionType { bookingIncome, refund, withdrawal }

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => TransactionType.bookingIncome,
      ),
      amount: (json['type'] == 'withdrawal' ? -(json['amount'] ?? 0).toDouble() : (json['amount'] ?? 0).toDouble()),
      date: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      description: json['description'] ?? '',
    );
  }
}

class EarningsModel {
  final double walletBalance;
  final double monthlyIncome;
  final double totalIncome;
  final double pendingPayments;
  final List<TransactionModel> transactions;

  EarningsModel({
    required this.walletBalance,
    required this.monthlyIncome,
    required this.totalIncome,
    required this.pendingPayments,
    required this.transactions,
  });

  factory EarningsModel.fromJson(Map<String, dynamic> json) {
    return EarningsModel(
      walletBalance: (json['availableBalance'] ?? 0).toDouble(),
      monthlyIncome: 0.0,
      totalIncome: 0.0,
      pendingPayments: 0.0,
      transactions: (json['transactions'] as List?)?.map((x) => TransactionModel.fromJson(x)).toList() ?? [],
    );
  }
}
