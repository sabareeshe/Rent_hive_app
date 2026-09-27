import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/listings_provider.dart';
import '../models/my_listing.dart';
import '../widgets/my_listing_card.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsState = ref.watch(myListingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: listingsState.when(
        data: (listings) {
          if (listings.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(myListingsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return MyListingCard(
                  listing: listing,
                  onEdit: () {
                    context.push('${AppRouter.addListing}?id=${listing.id}');
                  },
                  onDelete: () => _showDeleteDialog(context, ref, listing.id),
                  onTogglePause: () {
                    ref.read(myListingsProvider.notifier).togglePauseStatus(
                          listing.id,
                          listing.status == ListingStatus.paused,
                        );
                  },
                  onShare: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Share link copied to clipboard!')),
                    );
                  },
                  onOptions: () => _showListingOptions(context, index),
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to load listings', style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => ref.invalidate(myListingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRouter.addListing),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Listing', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.storefront_outlined, size: 80, color: AppColors.primary),
          ).animate().scale(duration: 500.ms),
          const SizedBox(height: 24),
          Text(
            'No Listings Yet',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
          const SizedBox(height: 8),
          Text(
            'Start earning money by listing your idle items.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push(AppRouter.addListing),
            child: const Text('Create Your First Listing'),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Listing?'),
        content: const Text('Are you sure you want to delete this listing? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(myListingsProvider.notifier).deleteListing(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listing deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  void _showListingOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: const Text('Duplicate Listing'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing duplicated')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.pause, color: Colors.orange),
                title: const Text('Pause Listing'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing paused')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined, color: Colors.grey),
                title: const Text('Archive Listing'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Listing archived')));
                },
              ),
              ListTile(
                leading: const Icon(Icons.rocket_launch, color: Colors.purple),
                title: const Text('Boost Listing'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Boost requested (Mock)')));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bar_chart, color: Colors.green),
                title: const Text('View Detailed Stats'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showListingStats(context, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showListingStats(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Listing Performance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Views', '${120 * (index + 1)}'),
                _buildStatColumn('Wishlists', '${15 * (index + 1)}'),
                _buildStatColumn('Bookings', '${3 * (index + 1)}'),
              ],
            ),
            const SizedBox(height: 24),
            Text('Revenue Generated: \$${(150 * (index + 1)).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
