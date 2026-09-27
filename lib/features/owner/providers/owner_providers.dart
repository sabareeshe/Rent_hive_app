import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_stats_model.dart';
import '../models/analytics_data_model.dart';
import '../models/earnings_model.dart';
import '../repositories/owner_repository.dart';
import '../repositories/analytics_repository.dart';
import '../repositories/earnings_repository.dart';

import '../../../core/network/api_client.dart';

// Repositories
final ownerRepositoryProvider = Provider<OwnerRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return OwnerRepository(dio);
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AnalyticsRepository(dio);
});

final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return EarningsRepository(dio);
});

// Providers
final dashboardStatsProvider = FutureProvider<DashboardStatsModel>((ref) async {
  return ref.read(ownerRepositoryProvider).getDashboardStats();
});

// Analytics filtering state
final analyticsFilterProvider = NotifierProvider<AnalyticsFilterNotifier, String>(() {
  return AnalyticsFilterNotifier();
});

class AnalyticsFilterNotifier extends Notifier<String> {
  @override
  String build() => 'Monthly';

  void setFilter(String filter) {
    state = filter;
  }
}

final analyticsDataProvider = FutureProvider<AnalyticsDataModel>((ref) async {
  final filter = ref.watch(analyticsFilterProvider);
  return ref.read(analyticsRepositoryProvider).getAnalytics(filter);
});

// Earnings Provider
final earningsProvider = AsyncNotifierProvider<EarningsNotifier, EarningsModel>(() {
  return EarningsNotifier();
});

class EarningsNotifier extends AsyncNotifier<EarningsModel> {
  @override
  Future<EarningsModel> build() async {
    return ref.read(earningsRepositoryProvider).getEarnings();
  }

  Future<void> requestWithdrawal(double amount, String details) async {
    state = const AsyncLoading();
    try {
      await ref.read(earningsRepositoryProvider).requestWithdrawal(amount, details);
      // Reload earnings
      state = AsyncData(await ref.read(earningsRepositoryProvider).getEarnings());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
