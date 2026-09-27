import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../providers/notification_provider.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).markAllAsRead();
            },
            child: const Text('Mark all as read'),
          ),
        ],
      ),
      body: notificationsState.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications'));
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notif = notifications[index];
              return ListTile(
                tileColor: notif.isRead ? Colors.transparent : Colors.blue.withValues(alpha: 0.05),
                onTap: () {
                  ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                },
                leading: _buildIcon(notif.type),
                title: Text(
                  notif.title,
                  style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notif.body),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, h:mm a').format(notif.timestamp),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: notif.isRead
                    ? null
                    : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildIcon(NotificationType type) {
    IconData icon;
    Color color;

    switch (type) {
      case NotificationType.booking:
        icon = Icons.event_available;
        color = Colors.green;
        break;
      case NotificationType.message:
        icon = Icons.chat;
        color = Colors.blue;
        break;
      case NotificationType.reminder:
        icon = Icons.alarm;
        color = Colors.orange;
        break;
      case NotificationType.system:
        icon = Icons.info;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
