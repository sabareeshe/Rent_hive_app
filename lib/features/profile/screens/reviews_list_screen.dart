import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/review_provider.dart';

class ReviewsListScreen extends ConsumerWidget {
  final String targetId;

  const ReviewsListScreen({super.key, required this.targetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsState = ref.watch(reviewsProvider(targetId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      body: reviewsState.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }

          final avg = reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header Distribution
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < avg.round() ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 16,
                        )),
                      ),
                      const SizedBox(height: 4),
                      Text('${reviews.length} reviews', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final starCount = 5 - index;
                        final count = reviews.where((r) => r.rating.round() == starCount).length;
                        final ratio = count / reviews.length;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text('$starCount', style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  backgroundColor: Colors.grey.shade200,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const Divider(height: 48),
              
              // List
              ...reviews.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundImage: CachedNetworkImageProvider(r.reviewerAvatar)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(DateFormat.yMMMd().format(r.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text(r.rating.toStringAsFixed(1)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(r.comment),
                  ],
                ),
              )),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
