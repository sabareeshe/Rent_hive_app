import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/my_listing.dart';
import '../../../core/theme/app_colors.dart';

class MyListingCard extends StatelessWidget {
  final MyListing listing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePause;
  final VoidCallback onShare;
  final VoidCallback onOptions;

  const MyListingCard({
    super.key,
    required this.listing,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePause,
    required this.onShare,
    required this.onOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(listing.images.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              listing.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        listing.category,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${listing.pricePerDay.toStringAsFixed(0)} / day',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Stats
                      Row(
                        children: [
                          const Icon(Icons.visibility_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${listing.totalViews} views', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 16),
                          const Icon(Icons.bookmark_border, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${listing.totalBookings} bookings', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textPrimaryLight),
                ),
                TextButton.icon(
                  onPressed: onTogglePause,
                  icon: Icon(
                    listing.status == ListingStatus.paused ? Icons.play_arrow_outlined : Icons.pause_circle_outline,
                    size: 18,
                  ),
                  label: Text(listing.status == ListingStatus.paused ? 'Resume' : 'Pause'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.textPrimaryLight),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'share') onShare();
                    if (value == 'delete') onDelete();
                    if (value == 'options') onOptions();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'options',
                      child: Row(
                        children: [
                          Icon(Icons.more_horiz, size: 18),
                          SizedBox(width: 8),
                          Text('More Options'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    switch (listing.status) {
      case ListingStatus.available:
        color = Colors.green;
        text = 'Available';
        break;
      case ListingStatus.booked:
        color = Colors.orange;
        text = 'Booked';
        break;
      case ListingStatus.paused:
        color = Colors.grey;
        text = 'Paused';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
