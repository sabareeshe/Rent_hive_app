import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../../profile/providers/profile_provider.dart';
import '../../listings/providers/listings_provider.dart';
import '../../bookings/providers/bookings_provider.dart';

final authProvider = AsyncNotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final repo = ref.watch(authRepositoryProvider);
    return await repo.checkAuthStatus();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.login(email, password);
      ref.invalidate(currentUserProvider);
      ref.invalidate(myListingsProvider);
      ref.invalidate(myBookingsProvider);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(
        name: name,
        username: username,
        email: email,
        password: password,
      );
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.logout();
      ref.invalidate(currentUserProvider);
      ref.invalidate(myListingsProvider);
      ref.invalidate(myBookingsProvider);
      state = const AsyncValue.data(false);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> forgotPassword(String email) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.forgotPassword(email);
  }
}
