import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/my_listing.dart';
import '../repositories/listings_repository.dart';
import '../../../core/network/api_client.dart';
import '../../home/models/rental_item.dart';
import '../../home/data/mock_rentals.dart';

final listingsRepositoryProvider = Provider<ListingsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ListingsRepository(dio);
});

// Global provider for all public listings available to any user
final publicListingsProvider = FutureProvider<List<RentalItem>>((ref) async {
  final dio = ref.watch(dioProvider);
  final myListings = ref.watch(myListingsProvider).value ?? [];

  List<RentalItem> serverItems = [];
  try {
    final response = await dio.get('/listings');
    final rawList = response.data as List;
    serverItems = rawList.map((x) => RentalItem.fromJson(x)).toList();
  } catch (e) {
    // If Render cold-starts or delays, serverItems remains empty
  }

  // Map user's listings into RentalItems
  final myRentalItems = myListings.map((l) => RentalItem(
    id: l.id,
    name: l.title,
    images: l.images.isNotEmpty ? l.images : ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800'],
    pricePerDay: l.pricePerDay,
    rating: 5.0,
    reviewsCount: 1,
    distance: 1.0,
    ownerName: 'You (Owner)',
    ownerAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=${l.id}',
    category: l.category,
    paymentNumber: l.paymentNumber,
  )).toList();

  final seenIds = <String>{};
  final List<RentalItem> combined = [];

  // 1. User's newly created/saved listings
  for (final item in myRentalItems) {
    if (seenIds.add(item.id)) {
      combined.add(item);
    }
  }

  // 2. Real server listings from other users and self
  for (final item in serverItems) {
    if (seenIds.add(item.id)) {
      combined.add(item);
    }
  }

  // 3. Fallback mock rentals
  for (final item in mockRentals) {
    if (seenIds.add(item.id)) {
      combined.add(item);
    }
  }

  return combined;
});

// Single source of truth to resolve any listing item by id
final rentalItemByIdProvider = Provider.family<RentalItem, String>((ref, id) {
  // 1. Check public listings (all users' listings fetched from server)
  final publicItems = ref.watch(publicListingsProvider).value;
  if (publicItems != null) {
    final found = publicItems.where((i) => i.id == id).firstOrNull;
    if (found != null) return found;
  }

  // 2. Check my listings (for current owner before network refresh)
  final myListings = ref.watch(myListingsProvider).value;
  if (myListings != null) {
    final found = myListings.where((l) => l.id == id).firstOrNull;
    if (found != null) {
      return RentalItem(
        id: found.id,
        name: found.title,
        images: found.images.isNotEmpty ? found.images : ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=800'],
        pricePerDay: found.pricePerDay,
        rating: 5.0,
        reviewsCount: 1,
        distance: 1.0,
        ownerName: 'Verified Owner',
        ownerAvatar: 'https://api.dicebear.com/7.x/bottts/png?seed=${found.id}',
        category: found.category,
        paymentNumber: found.paymentNumber,
      );
    }
  }

  // 3. Fallback to mock rentals
  return mockRentals.firstWhere(
    (item) => item.id == id,
    orElse: () => mockRentals.first,
  );
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
      final created = await repository.addListing(listing, imagePaths: imagePaths);
      final currentList = state.value ?? [];
      state = AsyncData([
        created,
        ...currentList.where((l) => l.id != listing.id && l.id != created.id),
      ]);
      ref.invalidate(publicListingsProvider);
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
      try {
        final prefs = await SharedPreferences.getInstance();
        if (state.value != null) {
          await prefs.setString(
            'cached_my_listings',
            jsonEncode(state.value!.map((e) => e.toJson()..['_id'] = e.id).toList()),
          );
        }
      } catch (_) {}
      ref.invalidate(publicListingsProvider);
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
      try {
        final prefs = await SharedPreferences.getInstance();
        if (state.value != null) {
          await prefs.setString(
            'cached_my_listings',
            jsonEncode(state.value!.map((e) => e.toJson()..['_id'] = e.id).toList()),
          );
        }
      } catch (_) {}
      ref.invalidate(publicListingsProvider);
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
