import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../providers/settings_provider.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: settingsState.when(
        data: (settings) {
          return ListView(
            children: [
              _buildSectionHeader('Account'),
              _buildListTile(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: () => context.push(AppRouter.editProfile),
              ),
              
              _buildSectionHeader('Preferences'),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark themes'),
                value: settings.isDarkMode,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).toggleDarkMode(val);
                },
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive rental updates and messages'),
                value: settings.pushNotificationsEnabled,
                onChanged: (val) {
                  final newSettings = settings.copyWith(pushNotificationsEnabled: val);
                  ref.read(settingsProvider.notifier).updateSettings(newSettings);
                },
              ),

              _buildSectionHeader('Security'),
              _buildListTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                onTap: () => _showChangePasswordDialog(context, ref),
              ),

              const Divider(height: 32),
              
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go(AppRouter.login);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                onTap: () => _showDeleteDialog(context, ref),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
      ),
    );
  }

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap, Widget? trailing}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isUpdating = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      final newPass = passwordCtrl.text.trim();
                      final confirmPass = confirmCtrl.text.trim();

                      if (newPass.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must be at least 6 characters')),
                        );
                        return;
                      }

                      if (newPass != confirmPass) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match')),
                        );
                        return;
                      }

                      setDialogState(() => isUpdating = true);
                      try {
                        await ref.read(profileRepositoryProvider).changePassword(newPass);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password updated successfully!')),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isUpdating = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update password: $e')),
                          );
                        }
                      }
                    },
              child: isUpdating
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(profileRepositoryProvider).deleteAccount();
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go(AppRouter.login);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
