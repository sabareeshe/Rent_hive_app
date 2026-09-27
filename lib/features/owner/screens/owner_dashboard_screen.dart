import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/owner_providers.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Switch to Renter Mode',
            onPressed: () {
              // Switch back to normal app
              context.go(AppRouter.home);
            },
          ),
        ],
      ),
      body: statsState.when(
        data: (stats) {
          return RefreshIndicator(
            onRefresh: () async {
              // ignore: unused_result
              ref.refresh(dashboardStatsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildWelcomeHeader(),
                const SizedBox(height: 24),
                _buildSectionTitle('Overview'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Total Earnings', '\$${stats.totalEarnings.toStringAsFixed(2)}', Icons.attach_money, AppColors.primary, context),
                    const SizedBox(width: 16),
                    _buildStatCard('Active Rentals', '${stats.activeRentals}', Icons.loop, Colors.orange, context),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStatCard('Pending Requests', '${stats.pendingRequests}', Icons.pending_actions, Colors.redAccent, context),
                    const SizedBox(width: 16),
                    _buildStatCard('Completed', '${stats.completedRentals}', Icons.check_circle_outline, Colors.green, context),
                  ],
                ),
                const SizedBox(height: 32),
                _buildSectionTitle('Quick Actions'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFE3F2FD), child: Icon(Icons.analytics_outlined, color: Colors.blue)),
                  title: const Text('View Detailed Analytics'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRouter.ownerAnalytics),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFFF3E5F5), child: Icon(Icons.picture_as_pdf_outlined, color: Colors.purple)),
                  title: const Text('Generate Reports'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRouter.ownerReports),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=owner_123'),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Welcome back,', style: TextStyle(color: Colors.grey, fontSize: 14)),
            Text('Mohan Kumar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
