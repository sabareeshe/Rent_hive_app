import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_data_model.dart';
import '../providers/owner_providers.dart';

class OwnerAnalyticsScreen extends ConsumerWidget {
  const OwnerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(analyticsFilterProvider);
    final analyticsState = ref.watch(analyticsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['Weekly', 'Monthly', 'Yearly'].map((f) {
                final isSelected = filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(analyticsFilterProvider.notifier).setFilter(f);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          Expanded(
            child: analyticsState.when(
              data: (data) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildChartCard('Revenue Timeline', data.revenueTimeline, Colors.green),
                    const SizedBox(height: 16),
                    _buildChartCard('Booking Trends', data.bookingTrends, Colors.blue),
                    const SizedBox(height: 16),
                    _buildChartCard('Top Categories', data.topCategories, Colors.orange),
                    const SizedBox(height: 16),
                    _buildChartCard('Listing Performance', data.listingPerformance, Colors.purple),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, List<ChartDataPoint> data, Color barColor) {
    if (data.isEmpty) return const SizedBox.shrink();

    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...data.map((point) {
              final ratio = maxValue == 0 ? 0.0 : point.value / maxValue;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(point.label, style: const TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio,
                            child: Container(
                              height: 12,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(point.value.toStringAsFixed(0), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
