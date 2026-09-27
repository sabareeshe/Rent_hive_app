import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import 'wishlist_provider.dart';

final notificationsProvider = AsyncNotifierProvider<NotificationsNotifier, List<NotificationModel>>(() {
  return NotificationsNotifier();
});

class NotificationsNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  Future<List<NotificationModel>> build() async {
    final repo = ref.read(engagementRepositoryProvider);
    return repo.getNotifications();
  }

  Future<void> markAsRead(String id) async {
    final repo = ref.read(engagementRepositoryProvider);
    
    if (state.value != null) {
      state = AsyncData([
        for (final n in state.value!)
          if (n.id == id) n.copyWith(isRead: true) else n
      ]);
    }

    try {
      await repo.markNotificationRead(id);
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  Future<void> markAllAsRead() async {
    final repo = ref.read(engagementRepositoryProvider);
    
    if (state.value != null) {
      state = AsyncData([
        for (final n in state.value!)
          n.copyWith(isRead: true)
      ]);
    }

    try {
      if (state.value != null) {
        for (final n in state.value!) {
          if (!n.isRead) {
            await repo.markNotificationRead(n.id);
          }
        }
      }
    } catch (e) {
      ref.invalidateSelf();
    }
  }

  int get unreadCount {
    return state.value?.where((n) => !n.isRead).length ?? 0;
  }
}
