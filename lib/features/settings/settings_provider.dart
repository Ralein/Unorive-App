import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:unorive/core/services/local_storage_service.dart';
import 'package:unorive/features/auth/auth_provider.dart';

part 'settings_provider.g.dart';

/// State representation of the user preferences settings.
class SettingsState {
  const SettingsState({
    required this.alarmSound,
    required this.defaultAlertRadius,
    required this.distanceUnit,
    required this.themeMode,
  });

  /// Path to chosen alarm sound asset.
  final String alarmSound;

  /// Default geofence alarm warning radius (meters).
  final double defaultAlertRadius;

  /// Distance format unit ('km' or 'mi').
  final String distanceUnit;

  /// Visual theme appearance preference ('light', 'dark', 'system').
  final String themeMode;

  /// Returns a copy of state with updated parameters.
  SettingsState copyWith({
    String? alarmSound,
    double? defaultAlertRadius,
    String? distanceUnit,
    String? themeMode,
  }) {
    return SettingsState(
      alarmSound: alarmSound ?? this.alarmSound,
      defaultAlertRadius: defaultAlertRadius ?? this.defaultAlertRadius,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// Notifier managing user preference configurations, saving changes directly to local storage.
@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  SettingsState build() {
    final storage = ref.watch(localStorageServiceProvider);
    return SettingsState(
      alarmSound: storage.getAlarmSound(),
      defaultAlertRadius: storage.getDefaultAlertRadius(),
      distanceUnit: storage.getDistanceUnit(),
      themeMode: storage.getThemeMode(),
    );
  }

  /// Updates and persists the alarm sound asset path.
  Future<void> updateAlarmSound(String sound) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setAlarmSound(sound);
    state = state.copyWith(alarmSound: sound);
  }

  /// Updates and persists the default warning geofence radius.
  Future<void> updateDefaultAlertRadius(double radius) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setDefaultAlertRadius(radius);
    state = state.copyWith(defaultAlertRadius: radius);
  }

  /// Updates and persists distance unit preference ('km' vs 'mi').
  Future<void> updateDistanceUnit(String unit) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setDistanceUnit(unit);
    state = state.copyWith(distanceUnit: unit);
  }

  /// Updates and persists light/dark theme preference.
  Future<void> updateThemeMode(String mode) async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.setThemeMode(mode);
    state = state.copyWith(themeMode: mode);
  }
}
