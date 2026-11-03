import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/rental_item.dart';

class RentalItemCard extends StatelessWidget {
  final RentalItem item;
  final VoidCallback onTap;

  const RentalItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Wishlist Icon
            Stack(
              children: [
                Hero(
                  tag: 'rental_image_${item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: item.images.isNotEmpty
                          ? item.images.first
                          : 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=600&auto=format&fit=crop',
                      height: 180,
                      width: 180,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 180,
                        width: 180,
                        color: Colors.grey.shade200,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        width: 180,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title & Price
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${item.pricePerDay.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  ' / day',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Rating and Distance
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  item.rating.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  ' (${item.reviewsCount})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                Text(
                  '${item.distance}km',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
