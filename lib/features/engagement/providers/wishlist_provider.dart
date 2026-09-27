import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/models/rental_item.dart';
import '../repositories/engagement_repository.dart';
import '../../../core/network/api_client.dart';

final engagementRepositoryProvider = Provider<EngagementRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return EngagementRepository(dio);
});

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<RentalItem>>(() {
  return WishlistNotifier();
});

class WishlistNotifier extends AsyncNotifier<List<RentalItem>> {
  @override
  Future<List<RentalItem>> build() async {
    final repo = ref.read(engagementRepositoryProvider);
    return repo.getWishlistItems();
  }

  Future<void> toggleItem(RentalItem item) async {
    final repo = ref.read(engagementRepositoryProvider);
    final previousState = state.value;

    if (previousState != null) {
      final isSaved = previousState.any((i) => i.id == item.id);
      
      // Optimistic update
      if (isSaved) {
        state = AsyncData(previousState.where((i) => i.id != item.id).toList());
      } else {
        state = AsyncData([...previousState, item]);
      }
    }

    try {
      await repo.toggleWishlist(item.id);
    } catch (e) {
      ref.invalidateSelf(); // Revert on failure
    }
  }
  
  bool isSaved(String id) {
    return state.value?.any((item) => item.id == id) ?? false;
  }
}
