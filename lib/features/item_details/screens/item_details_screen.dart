import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/router/app_router.dart';
import '../../home/models/rental_item.dart';
import '../../home/data/mock_rentals.dart';
import '../models/review.dart';
import '../../engagement/providers/wishlist_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ItemDetailsScreen extends ConsumerStatefulWidget {
  final String itemId;

  const ItemDetailsScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends ConsumerState<ItemDetailsScreen> {
  late RentalItem item;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch mock item by ID
    item = mockRentals.firstWhere(
      (element) => element.id == widget.itemId,
      orElse: () => mockRentals.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: Icon(
                  ref.watch(wishlistProvider.notifier).isSaved(item.id) 
                      ? Icons.favorite 
                      : Icons.favorite_border,
                  color: ref.watch(wishlistProvider.notifier).isSaved(item.id) 
                      ? Colors.red 
                      : Colors.black,
                ),
                onPressed: () {
                  ref.read(wishlistProvider.notifier).toggleItem(item);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.black),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Divider(height: 32),
                  _buildOwnerSection(),
                  const Divider(height: 32),
                  _buildDetailsSection(),
                  const Divider(height: 32),
                  _buildLocationSection(),
                  const Divider(height: 32),
                  _buildReviewsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildImageCarousel() {
    return Stack(
      children: [
        Hero(
          tag: 'rental_image_${item.id}',
          child: SizedBox(
            height: 350,
            child: PageView.builder(
              onPageChanged: (index) {
                setState(() => _currentImageIndex = index);
              },
              itemCount: item.images.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Could show interactive viewer
                  },
                  child: CachedNetworkImage(
                    imageUrl: item.images[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              item.images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentImageIndex == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              '${item.rating} (${item.reviewsCount} reviews)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.location_on, color: Colors.grey, size: 18),
            const SizedBox(width: 4),
            Text(
              '${item.distance}km away',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOwnerSection() {
    return GestureDetector(
      onTap: () => context.push('${AppRouter.publicProfile}?id=${item.id}_owner'),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundImage: CachedNetworkImageProvider('https://i.pravatar.cc/150?u=${item.ownerName.replaceAll(' ', '')}'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.ownerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Joined in 2022', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () => context.push('${AppRouter.chat}?id=c_1&name=${Uri.encodeComponent(item.ownerName)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Description', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(
          'This is a high quality rental item available for your next project or weekend getaway. It is well maintained and comes with all necessary accessories.',
          style: const TextStyle(height: 1.5, color: Colors.black87),
        ),
        const SizedBox(height: 24),
        Text('Pricing & Rules', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildInfoRow(Icons.calendar_today, 'Daily Rate', '\$${item.pricePerDay}/day'),
        _buildInfoRow(Icons.date_range, 'Weekly Rate', '\$${(item.pricePerDay * 6).toStringAsFixed(0)}/week'),
        _buildInfoRow(Icons.security, 'Security Deposit', '\$150 refundable'),
        _buildInfoRow(Icons.check_circle_outline, 'Condition', 'Like New'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(title)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    // Mock coordinates for NYC
    const LatLng pickupLocation = LatLng(40.7128, -74.0060);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pickup Location', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('123 Main St, New York, NY 10001 (Approximate)'),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: pickupLocation,
                zoom: 14,
              ),
              markers: {
                const Marker(
                  markerId: MarkerId('pickup_loc'),
                  position: pickupLocation,
                )
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextButton(
              onPressed: () => context.push('${AppRouter.reviewsList}?targetId=${item.id}'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...mockReviews.take(2).map((review) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(review.authorAvatarUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(review.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: index < review.rating ? Colors.amber : Colors.grey.shade300,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(review.comment, style: const TextStyle(height: 1.4)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${item.pricePerDay}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text('per day', style: TextStyle(color: Colors.grey)),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                context.push('${AppRouter.bookingCalendar}?itemId=${item.id}');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Check Availability'),
            ),
          ],
        ),
      ),
    );
  }
}
