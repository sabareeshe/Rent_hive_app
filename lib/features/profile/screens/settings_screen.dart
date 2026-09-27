import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../providers/settings_provider.dart';

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
              _buildListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy',
                onTap: () {},
              ),
              
              _buildSectionHeader('Preferences'),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                value: settings.isDarkMode,
                onChanged: (val) {
                  ref.read(settingsProvider.notifier).toggleDarkMode(val);
                },
              ),
              _buildListTile(
                icon: Icons.language,
                title: 'Language',
                trailing: Text(settings.language, style: const TextStyle(color: Colors.grey)),
                onTap: () {},
              ),
              SwitchListTile(
                secondary: const Icon(Icons.notifications_outlined),
                title: const Text('Push Notifications'),
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
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.security,
                title: 'Two-Factor Authentication',
                onTap: () {},
              ),

              _buildSectionHeader('Support'),
              _buildListTile(icon: Icons.help_outline, title: 'Help Center', onTap: () {}),
              _buildListTile(icon: Icons.contact_support_outlined, title: 'Contact Support', onTap: () {}),
              _buildListTile(icon: Icons.description_outlined, title: 'Terms & Conditions', onTap: () {}),

              const Divider(height: 32),
              
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  context.go(AppRouter.login);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                onTap: () => _showDeleteDialog(context),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRouter.login);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
