import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
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
      height: 105,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.push('${AppRouter.search}?query=${Uri.encodeComponent(cat)}');
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icons[index],
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      cat,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
