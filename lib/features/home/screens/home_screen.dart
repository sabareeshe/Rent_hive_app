import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../engagement/providers/notification_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/mock_rentals.dart';
import '../widgets/category_list.dart';
import '../widgets/promotional_carousel.dart';
import '../widgets/section_header.dart';
import '../widgets/rental_item_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final trendingItems = mockRentals.where((item) => item.rating >= 4.8).take(5).toList();
    final nearbyItems = mockRentals.where((item) => item.distance < 2.0).take(5).toList();
    final recommendedItems = mockRentals.skip(10).take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    final userAsyncValue = ref.watch(currentUserProvider);
                    final user = userAsyncValue.value;
                    
                    final firstName = user?.fullName.split(' ').first ?? 'User';
                    final location = (user != null && user.city.isNotEmpty && user.state.isNotEmpty) 
                        ? '${user.city}, ${user.state}' 
                        : 'Set Location';
                    final avatarUrl = user?.avatarUrl ?? 'https://i.pravatar.cc/150';

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, $firstName 👋',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.favorite_border, color: Colors.black),
                                onPressed: () => context.push(AppRouter.wishlist),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              child: IconButton(
                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.black),
                                onPressed: () => context.push(AppRouter.inbox),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Consumer(
                              builder: (context, ref, child) {
                                final unread = ref.watch(notificationsProvider.notifier).unreadCount;
                                return Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: IconButton(
                                        icon: const Icon(Icons.notifications_outlined, color: Colors.black),
                                        onPressed: () => context.push(AppRouter.notifications),
                                      ),
                                    ),
                                    if (unread > 0)
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: Text(
                                            unread.toString(),
                                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => context.go(AppRouter.profile),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(avatarUrl),
                                radius: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GestureDetector(
                  onTap: () => context.push(AppRouter.search),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 12),
                        Text('Search for items, categories...', style: TextStyle(color: Colors.grey)),
                        Spacer(),
                        Icon(Icons.tune, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 24),

              // Promotional Carousel
              const PromotionalCarousel().animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 16),

              // Categories
              SectionHeader(title: 'Categories', onSeeAll: () {}),
              CategoryList().animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

              const SizedBox(height: 16),

              // Trending Rentals
              SectionHeader(title: 'Trending Rentals', onSeeAll: () {}),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingItems.length,
                  itemBuilder: (context, index) {
                    return RentalItemCard(
                      item: trendingItems[index],
                      onTap: () {
                        context.push('${AppRouter.itemDetails}?itemId=${trendingItems[index].id}');
                      },
                    );
                  },
                ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),

              // Nearby Rentals
              SectionHeader(title: 'Nearby Items', onSeeAll: () {}),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: nearbyItems.length,
                  itemBuilder: (context, index) {
                    return RentalItemCard(
                      item: nearbyItems[index],
                      onTap: () {
                        context.push('${AppRouter.itemDetails}?itemId=${nearbyItems[index].id}');
                      },
                    );
                  },
                ),
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

              // Recommended Items
              SectionHeader(title: 'Recommended For You', onSeeAll: () {}),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 24),
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedItems.length,
                  itemBuilder: (context, index) {
                    return RentalItemCard(
                      item: recommendedItems[index],
                      onTap: () {
                        context.push('${AppRouter.itemDetails}?itemId=${recommendedItems[index].id}');
                      },
                    );
                  },
                ),
              ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
