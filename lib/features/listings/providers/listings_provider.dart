import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/my_listing.dart';
import '../repositories/listings_repository.dart';
import '../../../core/network/api_client.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ListingsRepository(dio);
});

final myListingsProvider = AsyncNotifierProvider<MyListingsNotifier, List<MyListing>>(() {
  return MyListingsNotifier();
});

class MyListingsNotifier extends AsyncNotifier<List<MyListing>> {
  @override
  Future<List<MyListing>> build() async {
    return _fetchListings();
  }

  Future<List<MyListing>> _fetchListings() async {
    final repository = ref.read(listingsRepositoryProvider);
    return repository.getMyListings();
  }

  Future<void> addListing(MyListing listing, {List<String>? imagePaths}) async {
    final repository = ref.read(listingsRepositoryProvider);
    // Optimistic update
    state = AsyncData([listing, ...?state.value]);
    try {
      await repository.addListing(listing, imagePaths: imagePaths);
    } catch (e) {
      // Revert on failure
      ref.invalidateSelf();
      rethrow;
    }
  }

  Future<void> updateListing(MyListing listing) async {
    final repository = ref.read(listingsRepositoryProvider);
    final previousState = state;
    if (state.value != null) {
      state = AsyncData([
        for (final l in state.value!)
          if (l.id == listing.id) listing else l
      ]);
    }
    try {
      await repository.updateListing(listing);
    } catch (e) {
      state = previousState;
      rethrow;
    }
  }

  Future<void> deleteListing(String id) async {
    final repository = ref.read(listingsRepositoryProvider);
    final previousState = state;
    if (state.value != null) {
      state = AsyncData(state.value!.where((l) => l.id != id).toList());
    }
    try {
      await repository.deleteListing(id);
    } catch (e) {
      state = previousState;
    }
  }

  Future<void> togglePauseStatus(String id, bool isPaused) async {
    final repository = ref.read(listingsRepositoryProvider);
    final newStatus = isPaused ? ListingStatus.available : ListingStatus.paused;
    
    final previousState = state;
    if (state.value != null) {
      state = AsyncData([
        for (final l in state.value!)
          if (l.id == id) l.copyWith(status: newStatus) else l
      ]);
    }
    
    try {
      if (isPaused) {
        await repository.resumeListing(id);
      } else {
        await repository.pauseListing(id);
      }
    } catch (e) {
      state = previousState;
    }
  }
}
