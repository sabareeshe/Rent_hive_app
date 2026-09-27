import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CategoryList extends StatelessWidget {
  final List<String> categories = [
    'Electronics',
    'Furniture',
    'Cameras',
    'Books',
    'Sports',
    'Gaming',
    'Vehicles',
    'Tools',
    'Home Appliances',
    'Musical Instruments'
  ];

  final List<IconData> icons = [
    Icons.computer,
    Icons.chair,
    Icons.camera_alt,
    Icons.menu_book,
    Icons.sports_basketball,
    Icons.videogame_asset,
    Icons.directions_car,
    Icons.handyman,
    Icons.kitchen,
    Icons.music_note,
  ];

  CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icons[index],
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[index],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
