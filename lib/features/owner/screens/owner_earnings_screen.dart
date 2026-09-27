import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/earnings_model.dart';
import '../providers/owner_providers.dart';

class OwnerEarningsScreen extends ConsumerStatefulWidget {
  const OwnerEarningsScreen({super.key});

  @override
  ConsumerState<OwnerEarningsScreen> createState() => _OwnerEarningsScreenState();
}

class _OwnerEarningsScreenState extends ConsumerState<OwnerEarningsScreen> {
  final _amountCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();

  void _showWithdrawalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Withdrawal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 16),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bankCtrl,
                decoration: InputDecoration(
                  labelText: 'Bank Account or UPI Details',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountCtrl.text) ?? 0.0;
                    final bank = _bankCtrl.text;
                    if (amount > 0 && bank.isNotEmpty) {
                      ref.read(earningsProvider.notifier).requestWithdrawal(amount, bank);
                      Navigator.pop(ctx);
                      _amountCtrl.clear();
                      _bankCtrl.clear();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Withdrawal Requested Successfully!')));
                    }
                  },
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Submit Request'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(earningsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings & Payments')),
      body: earningsState.when(
        data: (earnings) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Wallet Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.blue, Colors.indigo]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('\$${earnings.walletBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: earnings.walletBalance > 0 ? _showWithdrawalSheet : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.indigo,
                        ),
                        child: const Text('Withdraw Funds'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Summary Row
              Row(
                children: [
                  _buildSummaryBox('Monthly Income', '\$${earnings.monthlyIncome.toStringAsFixed(2)}', Colors.green),
                  const SizedBox(width: 16),
                  _buildSummaryBox('Pending', '\$${earnings.pendingPayments.toStringAsFixed(2)}', Colors.orange),
                ],
              ),
              const SizedBox(height: 32),

              // Transaction History
              const Text('Transaction History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ...earnings.transactions.map((tx) {
                IconData icon;
                Color color;
                if (tx.type == TransactionType.bookingIncome) {
                  icon = Icons.arrow_downward;
                  color = Colors.green;
                } else if (tx.type == TransactionType.withdrawal) {
                  icon = Icons.arrow_upward;
                  color = Colors.blue;
                } else {
                  icon = Icons.refresh;
                  color = Colors.orange;
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(icon, color: color),
                  ),
                  title: Text(tx.description),
                  subtitle: Text(DateFormat.yMMMd().format(tx.date)),
                  trailing: Text(
                    '${tx.amount > 0 ? '+' : ''}\$${tx.amount.abs().toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: tx.amount > 0 ? Colors.green : Colors.black),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSummaryBox(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
          ],
        ),
      ),
    );
  }
}
