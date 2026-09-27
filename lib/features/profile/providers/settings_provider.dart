import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import 'profile_provider.dart';

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsModel>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends AsyncNotifier<SettingsModel> {
  @override
  Future<SettingsModel> build() async {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getSettings();
  }

  Future<void> updateSettings(SettingsModel settings) async {
    final repo = ref.read(profileRepositoryProvider);
    
    // Optimistic UI update
    final previousState = state.value;
    state = AsyncData(settings);

    try {
      await repo.updateSettings(settings);
    } catch (e) {
      if (previousState != null) {
        state = AsyncData(previousState);
      }
    }
  }

  void toggleDarkMode(bool isDark) {
    if (state.value != null) {
      updateSettings(state.value!.copyWith(isDarkMode: isDark));
    }
  }
}
