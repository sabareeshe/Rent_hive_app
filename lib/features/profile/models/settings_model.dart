class SettingsModel {
  final bool isDarkMode;
  final String language;
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool locationServicesEnabled;

  SettingsModel({
    this.isDarkMode = false,
    this.language = 'English',
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.locationServicesEnabled = true,
  });

  SettingsModel copyWith({
    bool? isDarkMode,
    String? language,
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? locationServicesEnabled,
  }) {
    return SettingsModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      locationServicesEnabled: locationServicesEnabled ?? this.locationServicesEnabled,
    );
  }
}
