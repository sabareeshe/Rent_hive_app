import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRouter.settings),
          ),
        ],
      ),
      body: userState.when(
        data: (user) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Header
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user.avatarUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Image.network(
                                  'https://api.dicebear.com/7.x/bottts/png?seed=${user.id.isNotEmpty ? user.id : user.username}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          if (user.isVerified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.verified, color: Colors.white, size: 16),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(user.fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      if (user.username.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(user.email, style: const TextStyle(color: Colors.grey)),
                      if (user.phoneNumber.isNotEmpty || user.city.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            if (user.city.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(user.city, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            if (user.phoneNumber.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(user.phoneNumber, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => context.push(AppRouter.editProfile),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Edit Profile'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildStatCard('★ ${user.averageRating}', 'Rating', context),
                      _buildStatCard(user.totalListings.toString(), 'Listings', context),
                      _buildStatCard(user.totalRentals.toString(), 'Rentals', context),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Bio & Details
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(
                        user.bio.isNotEmpty ? user.bio : 'No bio added yet.',
                        style: const TextStyle(color: Colors.grey, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      if (user.phoneNumber.isNotEmpty)
                        _buildInfoRow(Icons.phone_outlined, user.phoneNumber),
                      _buildInfoRow(
                        Icons.location_on_outlined,
                        (user.city.isNotEmpty || user.state.isNotEmpty)
                            ? '${user.city}${user.city.isNotEmpty && user.state.isNotEmpty ? ', ' : ''}${user.state}'
                            : 'Location not set',
                      ),
                      _buildInfoRow(Icons.calendar_today_outlined, 'Joined ${user.memberSince.year}'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go(AppRouter.ownerHub),
                      icon: const Icon(Icons.storefront),
                      label: const Text('Manage My Business'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
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

  Widget _buildStatCard(String value, String label, BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: Colors.grey.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
