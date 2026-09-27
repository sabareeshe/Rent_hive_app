import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/router/app_router.dart';
import '../providers/profile_provider.dart';

class PublicProfileScreen extends ConsumerWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(publicProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {}, // Report user mockup
          )
        ],
      ),
      body: profileState.when(
        data: (user) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: CachedNetworkImageProvider(user.avatarUrl),
                      ),
                      const SizedBox(height: 12),
                      Text(user.fullName, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 18),
                          const SizedBox(width: 4),
                          Text('${user.averageRating} (${user.totalReviews} reviews)'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => context.push('${AppRouter.chat}?id=c_$userId&name=${Uri.encodeComponent(user.fullName)}'),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Message Owner'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Bio
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(user.bio, style: const TextStyle(color: Colors.grey, height: 1.5)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.verified_user, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(user.isVerified ? 'Identity Verified' : 'Not Verified'),
                        ],
                      ),
                    ],
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
}
