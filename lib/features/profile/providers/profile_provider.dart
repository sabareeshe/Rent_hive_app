import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../repositories/profile_repository.dart';
import '../../../core/network/api_client.dart';

final profileRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
});

final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, UserModel>(() {
  return CurrentUserNotifier();
});

class CurrentUserNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getCurrentUser();
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    final repo = ref.read(profileRepositoryProvider);
    state = const AsyncLoading();
    try {
      final user = await repo.updateProfile(updatedUser);
      state = AsyncData(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Global provider for fetching public profiles
final publicProfileProvider = FutureProvider.family<UserModel, String>((ref, userId) async {
  final repo = ref.read(profileRepositoryProvider);
  return repo.getPublicProfile(userId);
});
